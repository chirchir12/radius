defmodule Radius.Auth do
  import Ecto.Query, warn: false
  alias Radius.Repo
  alias Radius.Auth.{Hotspot, Ppoe, Radcheck}
  alias Radius.Pipeline.Jobs.SessionSchedular
  alias Radius.UserGroup.Radusergroup

  def login(:hotspot, attrs) do
    with {:ok, data} <- validate_login(%Hotspot{}, attrs),
         :ok <- check_session_exists(data.customer),
         {:ok, %Hotspot{} = data} <- Hotspot.login(data),
         {:ok, %Oban.Job{}} <- SessionSchedular.schedule(data.customer, data.duration_mins, :hotspot) do
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

  def fetch_expired_session(customer, service) do
    case Repo.transaction(fn ->
           with {:ok, {_, sessions}} <- Radcheck.delete_expired_check(customer, service),
           customer_ids <- sessions |> Enum.map(& &1.customer),
                {:ok, {_, _}} <- Radusergroup.delete_user_group(customer_ids) do
             {:ok, sessions}
           end
         end) do
      {:ok, {:ok, sessions}} -> {:ok, sessions}
      {:ok, {:error, reason}} -> {:error, reason}
      {:error, reason} -> {:error, reason}
    end
  end

  def fetch_expired_session() do
    case Repo.transaction(fn ->
           with {:ok, {_, sessions}} <- Radcheck.delete_expired_check(),
           customer_ids <- sessions |> Enum.map(& &1.customer),
                {:ok, {_, _}} <- Radusergroup.delete_user_group(customer_ids) do
             {:ok, sessions}
           end
         end) do
      {:ok, {:ok, sessions}} -> {:ok, sessions}
      {:ok, {:error, reason}} -> {:error, reason}
      {:error, reason} -> {:error, reason}
    end
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
