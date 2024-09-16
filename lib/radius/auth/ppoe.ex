defmodule Radius.Auth.Ppoe do
  alias Radius.Repo
  import Ecto.Query, warn: false
  alias Radius.Auth.Radcheck

  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :username, :string
    field :password, :string
    field :customer, :string
    field :service, :string, default: "ppp"
    field :duration_mins, :integer
    field :expire_on, :naive_datetime
    field :profile, :string
  end

  def changeset(ppoe, attrs) do
    ppoe
    |> cast(attrs, [:username, :password, :customer, :service, :duration_mins, :expire_on, :profile])
    |> validate_required([:username, :password, :customer, :duration_mins, :profile])
    |> validate_inclusion(:service, ["ppp"])
  end

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
      valid_credentials = cred_changeset.changes
      valid_profile = prof_changeset.changes

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

    case Repo.delete_all(query) do
      {0, nil} ->
        {:error, :customer_session_not_found}

      {count, nil} when is_integer(count) and count > 0 ->
        {:ok, :ok}

      {_, _} ->
        {:error, :delete_failed}
    end
  end
end
