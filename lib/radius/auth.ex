defmodule Radius.Auth do
  import Ecto.Query, warn: false
  alias Radius.Repo
  alias Radius.Auth.{Hotspot, Ppoe, Radcheck}

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



  def get_expired_sessions(:ppp) do
    now = DateTime.utc_now()
    query = from(r in Radcheck, where: r.expire_on < ^now and r.service == "ppp", select: r)
    {:ok, Repo.delete(query)}
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
