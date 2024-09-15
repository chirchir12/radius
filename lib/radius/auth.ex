defmodule Radius.Auth do
  import Ecto.Query, warn: false
  alias Radius.Repo
  alias Radius.Auth.{Hotspot, Ppoe, Radcheck}
  alias Radius.UserGroup.Radusergroup

  def login(:hotspot, attrs) do
    with {:ok, data} <- validate_login(%Hotspot{}, attrs),
         :ok <- check_session_exists(data.customer) do
      Hotspot.login(data)
    end
  end

  def login(:ppp, attrs) do
    with {:ok, data} <- validate_login(%Ppoe{}, attrs),
         :ok <- check_session_exists(data.customer) do
      Ppoe.login(data)
    end
  end

  def logout(:hotspot, customer) do
    Hotspot.logout(customer)
  end

  def logout(:ppp, customer) do
    Ppoe.logout(customer)
  end

  def extend_session(attrs) do
    changeset = Hotspot.extend_session_changeset(%Hotspot{}, attrs)

    case changeset.valid? do
      false ->
        {:error, changeset}

      true ->
        changes = changeset.changes
        Hotspot.extend_expiration(changes.customer, changes.expire_on)
    end
  end

  def clear_expired_sessions(:hotspot) do
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

  def get_expired_sessions(:ppp) do
    now = DateTime.utc_now()
    query = from(r in Radcheck, where: r.expire_on < ^now and r.service == "ppp", select: r)
    {:ok, Repo.delete(query)}
  end

  def test_select() do
    now = DateTime.utc_now()

    from(r in Radcheck, where: r.expire_on < ^now and r.service == "hotspot", select: r)
    |> Repo.delete_all()
  end

  def clear_session(session_ids) do
    query = from(r in Radcheck, where: r.id in ^session_ids)
    Repo.delete_all(query)
  end

  def clear_session_for(customers) do
    query = from(rg in Radusergroup, where: rg.customer in ^customers)

    case Repo.delete_all(query) do
      {0, nil} ->
        :ok

      {_, nil} ->
        :ok

      {_, _} ->
        :ok
    end
  end

  defp validate_login(%Hotspot{} = hotspot, attrs) do
    changeset = Hotspot.changeset(hotspot, attrs)

    case changeset.valid? do
      false ->
        {:error, changeset}

      true ->
        changes = changeset.changes

        data = %{
          hotspot
          | username: changes.username,
            password: changes.password,
            customer: changes.customer,
            service: "hotspot",
            expire_on: changes.expire_on,
            plan: changes.plan,
            priority: Map.get(changes, :priority, 10)
        }

        {:ok, data}
    end
  end

  defp validate_login(%Ppoe{} = ppoe, attrs) do
    changeset = Ppoe.changeset(ppoe, attrs)

    case changeset.valid? do
      false ->
        {:error, changeset}

      true ->
        changes = changeset.changes

        data = %{
          ppoe
          | username: changes.username,
            password: changes.password,
            customer: changes.customer,
            service: "ppp",
            expire_on: changes.expire_on,
            profile: changes.profile
        }

        {:ok, data}
    end
  end

  defp check_session_exists(customer) do
    case sessions(customer) do
      {:ok, []} ->
        :ok

      {:ok, [_ | _]} ->
        {:error, :session_exists}
    end
  end

  defp sessions(customer) do
    query = from(r in Radcheck, where: r.customer == ^customer)
    {:ok, Repo.all(query)}
  end
end
