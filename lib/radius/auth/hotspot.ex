defmodule Radius.Auth.Hotspot do
  alias Radius.Repo
  alias Radius.Auth.Radcheck
  alias Radius.UserGroup.Radusergroup
  import Ecto.Query

  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :username, :string
    field :password, :string
    field :customer, Ecto.UUID
    field :service, :string, default: "hotspot"
    field :duration_mins, :integer
    field :expire_on, :utc_datetime
    field :plan, Ecto.UUID
    field :priority, :integer, default: 0
    field :subscription, Ecto.UUID
  end

  def changeset(hotspot, attrs) do
    hotspot
    |> cast(attrs, [
      :username,
      :password,
      :customer,
      :service,
      :duration_mins,
      :plan,
      :priority,
      :expire_on,
      :subscription
    ])
    |> validate_required([:username, :password, :customer, :duration_mins, :plan])
    |> validate_inclusion(:service, ["hotspot"])
    |> validate_number(:priority, greater_than_or_equal_to: 0)
  end

  def extend_session_changeset(hotspot, attrs) do
    hotspot
    |> cast(attrs, [:customer, :duration_mins, :service])
    |> validate_required([:customer, :duration_mins, :service])
  end

  def login(%__MODULE__{} = hotspot) do
    check = %{
      username: hotspot.username,
      attribute: "Cleartext-Password",
      op: ":=",
      value: hotspot.password,
      customer: hotspot.customer,
      service: "hotspot",
      expire_on: hotspot.expire_on
    }

    subscription = %{
      username: hotspot.username,
      attribute: "Subscription-Id",
      op: ":=",
      value: hotspot.subscription,
      customer: hotspot.customer,
      service: "hotspot",
      expire_on: hotspot.expire_on
    }

    group = %{
      username: hotspot.username,
      groupname: hotspot.plan,
      customer: hotspot.customer,
      service: "hotspot",
      priority: hotspot.priority
    }

    case Repo.transaction(fn ->
           with {:ok, %Radcheck{}} <- Radcheck.create_radcheck(check),
                {:ok, %Radcheck{}} <- Radcheck.create_radcheck(subscription),
                {:ok, %Radusergroup{}} <- Radusergroup.create_radusergroup(group) do
             :ok
           end
         end) do
      {:ok, :ok} -> {:ok, hotspot}
      {:ok, {:error, reason}} -> {:error, reason}
      {:error, reason} -> {:error, reason}
    end
  end

  def logout(customer) do
    radcheck_query =
      from(r in Radcheck, where: r.customer == ^customer and r.service == ^"hotspot")

    radusergroup_query = from(r in Radusergroup, where: r.customer == ^customer)

    Repo.transaction(fn ->
      delete_records(radcheck_query, radusergroup_query)
    end)
    |> handle_transaction_result()
  end

  defp delete_records(radcheck_query, radusergroup_query) do
    {deleted_radcheck, _} = Repo.delete_all(radcheck_query)
    {deleted_radusergroup, _} = Repo.delete_all(radusergroup_query)

    if deleted_radcheck > 0 and deleted_radusergroup > 0 do
      :ok
    else
      {:error, :customer_session_not_found}
    end
  end

  defp handle_transaction_result(transaction_result) do
    case transaction_result do
      {:ok, :ok} -> {:ok, :ok}
      {:ok, {:error, reason}} -> {:error, reason}
      {:error, reason} -> {:error, reason}
    end
  end
end
