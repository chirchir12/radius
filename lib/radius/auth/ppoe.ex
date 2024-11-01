defmodule Radius.Auth.Ppoe do
  alias Radius.Repo
  import Ecto.Query, warn: false
  alias Radius.Auth.Radcheck

  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :username, :string
    field :password, :string
    field :customer, Ecto.UUID
    field :service, :string, default: "ppoe"
    field :duration_mins, :integer
    field :expire_on, :naive_datetime
    field :plan, Ecto.UUID
  end

  def changeset(ppoe, attrs) do
    ppoe
    |> cast(attrs, [
      :username,
      :password,
      :customer,
      :service,
      :duration_mins,
      :expire_on,
      :plan
    ])
    |> validate_required([:username, :password, :customer, :duration_mins, :plan])
    |> validate_inclusion(:service, ["ppoe"])
  end

  def extend_session_changeset(hotspot, attrs) do
    hotspot
    |> cast(attrs, [:customer, :duration_mins, :service])
    |> validate_required([:customer, :duration_mins, :service])
  end

  def login(%__MODULE__{} = ppoe) do
    credentials = %{
      username: ppoe.username,
      attribute: "Cleartext-Password",
      op: ":=",
      value: ppoe.password,
      customer: ppoe.customer,
      service: "ppoe",
      expire_on: ppoe.expire_on
    }

    profile = %{
      username: ppoe.username,
      attribute: "User-Profile",
      op: ":=",
      value: ppoe.plan,
      customer: ppoe.customer,
      service: "ppoe",
      expire_on: ppoe.expire_on
    }

    cred_changeset = Radcheck.changeset(%Radcheck{}, credentials)
    prof_changeset = Radcheck.changeset(%Radcheck{}, profile)

    if cred_changeset.valid? and prof_changeset.valid? do
      valid_credentials = cred_changeset.changes
      valid_profile = prof_changeset.changes

      case Repo.insert_all(Radcheck, [valid_credentials, valid_profile]) do
        {2, nil} ->
          {:ok, ppoe}

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

  def update_username_password(%{customer: customer, username: username, password: password}) do
    query = from rc in Radcheck,
        where: rc.customer == ^customer and rc.attribute == "Cleartext-Password",
        update: [set: [username: ^username, value: ^password]]
       _ =  Repo.update_all(query, [])
       :ok
  end

  def update_plan(%{customer: customer, username: username, plan: plan}) do
    query = from rc in Radcheck,
        where: rc.customer == ^customer and rc.attribute == "User-Profile",
        update: [set: [username: ^username, value: ^plan]]
       _ =  Repo.update_all(query, [])
       :ok
  end
end
