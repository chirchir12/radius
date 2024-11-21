defmodule Radius.Auth.Ppoe do
  @moduledoc """
  Functionality to auth PPP users
  Note: subscription_uuid becomes customer
  """
  alias Radius.Repo
  import Ecto.Query, warn: false
  alias Radius.Auth.Radcheck

  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :username, :string
    field :password, :string
    field :subscription_uuid, Ecto.UUID
    field :service, :string, default: "ppoe"
    field :duration_mins, :integer
    field :expire_on, :utc_datetime
    field :plan, Ecto.UUID
  end

  def changeset(ppoe, attrs) do
    ppoe
    |> cast(attrs, [
      :username,
      :password,
      :subscription_uuid,
      :service,
      :duration_mins,
      :expire_on,
      :plan
    ])
    |> validate_required([:username, :password, :subscription_uuid, :duration_mins, :plan])
    |> validate_inclusion(:service, ["ppoe"])
  end

  def extend_session_changeset(hotspot, attrs) do
    hotspot
    |> cast(attrs, [:subscription_uuid, :duration_mins, :service])
    |> validate_required([:subscription_uuid, :duration_mins, :service])
  end

  def login(%__MODULE__{} = ppoe) do
    credentials = %{
      username: ppoe.username,
      attribute: "Cleartext-Password",
      op: ":=",
      value: ppoe.password,
      customer: ppoe.subscription_uuid,
      service: "ppoe",
      expire_on: ppoe.expire_on
    }

    subscription = %{
      username: ppoe.username,
      attribute: "Subscription-Id",
      op: ":=",
      value: ppoe.subscription_uuid,
      customer: ppoe.subscription_uuid,
      service: "ppoe",
      expire_on: ppoe.expire_on
    }

    profile = %{
      username: ppoe.username,
      attribute: "User-Profile",
      op: ":=",
      value: ppoe.plan,
      customer: ppoe.subscription_uuid,
      service: "ppoe",
      expire_on: ppoe.expire_on
    }

    cred_changeset = Radcheck.changeset(%Radcheck{}, credentials)
    prof_changeset = Radcheck.changeset(%Radcheck{}, profile)
    sub_changeset = Radcheck.changeset(%Radcheck{}, subscription)

    if cred_changeset.valid? and prof_changeset.valid? and sub_changeset.valid? do
      valid_credentials = cred_changeset.changes
      valid_profile = prof_changeset.changes
      valid_subscription = sub_changeset.changes

      case Repo.insert_all(Radcheck, [valid_credentials, valid_profile, valid_subscription]) do
        {2, nil} ->
          {:ok, ppoe}

        {_, _errors} ->
          {:error, %{credentials: cred_changeset, profile: prof_changeset}}
      end
    else
      {:error, %{credentials: cred_changeset, profile: prof_changeset}}
    end
  end

  def logout(subscription_uuid) do
    query = from(r in Radcheck, where: r.customer == ^subscription_uuid)

    case Repo.delete_all(query) do
      {0, nil} ->
        {:error, :customer_session_not_found}

      {count, nil} when is_integer(count) and count > 0 ->
        {:ok, :ok}

      {_, _} ->
        {:error, :delete_failed}
    end
  end

  def update_username_password(
        %{
          subscription_uuid: subscription_uuid,
          username: username,
          password: password
        } = params
      ) do
    query =
      from rc in Radcheck,
        where: rc.customer == ^subscription_uuid and rc.attribute == "Cleartext-Password",
        update: [set: [username: ^username, value: ^password]]

    _ = update_plan(params)

    _ = Repo.update_all(query, [])
    :ok
  end

  def update_plan(%{subscription_uuid: subscription_uuid, username: username, plan: plan}) do
    query =
      from rc in Radcheck,
        where: rc.customer == ^subscription_uuid and rc.attribute == "User-Profile",
        update: [set: [username: ^username, value: ^plan]]

    _ = Repo.update_all(query, [])
    :ok
  end
end
