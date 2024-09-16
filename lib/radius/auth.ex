defmodule Radius.Auth do
  import Ecto.Query, warn: false
  alias Radius.Repo
  alias Radius.Auth.{Hotspot, Ppoe, Radcheck}
  alias Radius.Workers.HotspotSessionPruner

  def login(:hotspot, attrs) do
    with {:ok, data} <- validate_login(%Hotspot{}, attrs),
         :ok <- check_session_exists(data.customer),
         {:ok, %Hotspot{} = data} <- Hotspot.login(data) do
      prun_after = data.duration_mins * 60
      # HotspotSessionPruner.enqueue(data.customer, prun_after, "hotspot")
      {:ok, data}
    end
  end

  def login(:ppoe, attrs) do
    with {:ok, data} <- validate_login(%Ppoe{}, attrs),
         :ok <- check_session_exists(data.customer) do
      Ppoe.login(data)
    end
  end

  def logout(:hotspot, customer) do
    Hotspot.logout(customer)
  end

  def logout(:ppoe, customer) do
    Ppoe.logout(customer)
  end

  def extend_session(attrs) do
    changeset = Hotspot.extend_session_changeset(%Hotspot{}, attrs)

    case changeset.valid? do
      false ->
        {:error, changeset}

      true ->
        changes = changeset.changes
        now = DateTime.utc_now()
        expire_on = DateTime.add(now, changes.duration_mins * 60, :second)
        Hotspot.extend_expiration(changes.customer, expire_on)
    end
  end

  def get_expired_sessions(:ppoe) do
    now = DateTime.utc_now()
    query = from(r in Radcheck, where: r.expire_on < ^now and r.service == "ppoe", select: r)
    {:ok, Repo.delete(query)}
  end

  defp validate_login(%Hotspot{} = hotspot, attrs) do
    changeset = Hotspot.changeset(hotspot, attrs)

    case changeset.valid? do
      false ->
        {:error, changeset}

      true ->
        changes = changeset.changes
        now = DateTime.utc_now()
        expire_on = DateTime.add(now, changes.duration_mins * 60, :second)

        data = %{
          hotspot
          | username: changes.username,
            password: changes.password,
            customer: changes.customer,
            service: "hotspot",
            expire_on: expire_on,
            plan: changes.plan,
            priority: Map.get(changes, :priority, 10),
            duration_mins: changes.duration_mins
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
        now = DateTime.utc_now()
        expire_on = DateTime.add(now, changes.duration_mins * 60, :second)

        data = %{
          ppoe
          | username: changes.username,
            password: changes.password,
            customer: changes.customer,
            service: "ppoe",
            expire_on: expire_on,
            profile: changes.profile,
            duration_mins: changes.duration_mins
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
