defmodule Radius.Auth.Ppoe do
  alias Radius.Repo
  alias Radius.Auth.Radcheck

  defstruct username: nil,
            password: nil,
            customer: nil,
            service: "ppoe",
            expire_on: nil,
            profile: nil

  def login(%__MODULE__{} = attrs) do
    credentials = %{
      username: attrs.username,
      attribute: "Cleartext-Password",
      op: ":=",
      value: attrs.password,
      customer: attrs.customer,
      service: "ppoe",
      expire_on: attrs.expire_on
    }

    profile = %{
      username: attrs.username,
      attribute: "User-Profile",
      op: ":=",
      value: attrs.profile,
      customer: attrs.customer,
      service: "ppoe",
      expire_on: attrs.expire_on
    }

    cred_changeset = Radcheck.changeset(%Radcheck{}, credentials)
    prof_changeset = Radcheck.changeset(%Radcheck{}, profile)

    if cred_changeset.valid? and prof_changeset.valid? do
      valid_credentials = Ecto.Changeset.apply_changes(cred_changeset)
      valid_profile = Ecto.Changeset.apply_changes(prof_changeset)
      Repo.insert_all(Radcheck, [valid_credentials, valid_profile])
    else
      {:error, %{credentials: cred_changeset.errors, profile: prof_changeset.errors}}
    end
  end

  def logout(customer) do
    Repo.delete_all(Radcheck, customer: customer)
  end
end
