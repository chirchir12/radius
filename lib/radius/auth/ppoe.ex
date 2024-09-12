defmodule Radius.Auth.Ppoe do
  alias Radius.Repo
  import Ecto.Query, warn: false
  alias Radius.Auth.Radcheck

  defstruct username: nil,
            password: nil,
            customer: nil,
            service: "ppp",
            expire_on: nil,
            profile: nil

  def login(%__MODULE__{} = attrs) do
    credentials = %{
      username: attrs.username,
      attribute: "Cleartext-Password",
      op: ":=",
      value: attrs.password,
      customer: attrs.customer,
      service: "ppp",
      expire_on: attrs.expire_on
    }

    profile = %{
      username: attrs.username,
      attribute: "User-Profile",
      op: ":=",
      value: attrs.profile,
      customer: attrs.customer,
      service: "ppp",
      expire_on: attrs.expire_on
    }

    cred_changeset = Radcheck.changeset(%Radcheck{}, credentials)
    prof_changeset = Radcheck.changeset(%Radcheck{}, profile)

    if cred_changeset.valid? and prof_changeset.valid? do
      valid_credentials = cred_changeset.changes |> remove_service()
      valid_profile = prof_changeset.changes |> remove_service()

      case Repo.insert_all(Radcheck, [valid_credentials, valid_profile]) do
        {2, nil} ->
          {:ok, :ok}

        {_, _errors} ->
          {:error, %{credentials: cred_changeset, profile: prof_changeset}}
      end
    else
      {:error, %{credentials: cred_changeset, profile: prof_changeset}}
    end
  end

  def logout(customer) do
    query = from(r in Radcheck, where: r.customer == ^customer)
    Repo.delete_all(query)
  end

  defp remove_service(attrs) do
    Map.delete(attrs, :service)
  end
end
