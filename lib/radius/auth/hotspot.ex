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
    field :customer, :string
    field :service, :string, default: "hotspot"
    field :duration_mins, :integer
    field :expire_on, :utc_datetime
    field :plan, :string
    field :priority, :integer, default: 0
  end

  def changeset(hotspot, attrs) do
    hotspot
    |> cast(attrs, [:username, :password, :customer, :service, :duration_mins, :plan, :priority, :expire_on])
    |> validate_required([:username, :password, :customer, :duration_mins, :plan])
    |> validate_inclusion(:service, ["hotspot"])
    |> validate_number(:priority, greater_than_or_equal_to: 0)
  end

  def extend_session_changeset(hotspot, attrs) do
    hotspot
    |> cast(attrs, [:customer, :duration_mins])
    |> validate_required([:customer, :duration_mins])
  end

  def login(%__MODULE__{} = hotspot) do
    check = %{
      username: hotspot.username,
      attribute: "Cleartext-Password",
      op: "==",
      value: hotspot.password,
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
                {:ok, %Radusergroup{}} <- Radusergroup.create_radusergroup(group) do
             :ok
           end
         end) do
      {:ok, :ok} -> {:ok, hotspot}
      {:ok, {:error, reason}} -> {:error, reason}
      {:error, reason} -> {:error, reason}
    end
  end

  def extend_expiration(customer, new_expire_on) do
    query =
      from(r in Radcheck,
        where: r.customer == ^customer
      )

    case Repo.update_all(query, set: [expire_on: new_expire_on]) do
      {0, _} -> {:error, :customer_session_not_found}
      {_, _} -> {:ok, :ok}
    end
  end

  def logout(customer) do
    radcheck_query = from(r in Radcheck, where: r.customer == ^customer and r.service == ^"hotspot")
    radusergroup_query = from(r in Radusergroup, where: r.customer == ^customer)

    Repo.transaction(fn ->
      delete_records(radcheck_query, radusergroup_query)
    end)
    |> handle_transaction_result()
  end

  def expired_sessions() do
    case Repo.transaction(fn ->
           with {:ok, {_, customers}} <- clear_hotspot_auth_and_select(),
                customer_ids <- customers |> Enum.map(& &1.customer),
                {:ok, _} <- clear_hotspot_usergroup(customer_ids) do
             {:ok, customers}
           end
         end) do
      {:ok, {:ok, customers}} -> {:ok, customers}
      {:ok, {:error, reason}} -> {:error, reason}
      {:error, reason} -> {:error, reason}
    end
  end

  defp clear_hotspot_auth_and_select() do
    now = DateTime.utc_now()
    query1 = from(r in Radcheck, where: r.expire_on < ^now and r.service == "hotspot", select: r)
    {:ok, Repo.delete_all(query1)}
  end

  defp clear_hotspot_usergroup(customers) do
    query2 = from(r in Radusergroup, where: r.customer in ^customers)
    {:ok, Repo.delete_all(query2)}
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
