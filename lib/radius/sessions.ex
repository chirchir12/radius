defmodule Radius.Sessions do
  alias Radius.Auth.{Hotspot, Ppoe, Radcheck}
  alias Radius.UserGroup.Radusergroup
  import Ecto.Query, warn: false
  alias Radius.Repo

  def fetch_expired_session(customer, service) do
    case Radcheck.fetch_and_delete_expired_check(customer, service) do
      {:ok, sessions} ->
        case service do
          "hotspot" ->
            customer_ids = get_customer_ids(sessions)
            _ = delete_user_group(customer_ids)
            {:ok, sessions}

          "ppoe" ->
            {:ok, sessions}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  def fetch_expired_sessions_after(in_mins) do
    case Radcheck.fetch_and_delete_expired_after(in_mins) do
      {:ok, sessions} ->
        {:ok, sessions}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def extend_session(customer, duration_mins, "ppoe") do
    %{"customer" => customer, "duration_mins" => duration_mins, "service" => "ppoe"}
    |> extend_session()
  end

  def extend_session(customer, duration_mins, "hotspot") do
    %{"customer" => customer, "duration_mins" => duration_mins, "service" => "hotspot"}
    |> extend_session()
  end

  def extend_session(attrs) do
    changeset =
      case Map.get(attrs, "service") do
        "hotspot" ->
          Hotspot.extend_session_changeset(%Hotspot{}, attrs)

        "ppoe" ->
          Ppoe.extend_session_changeset(%Ppoe{}, attrs)
      end

    case changeset.valid? do
      false ->
        {:error, changeset}

      true ->
        changes = changeset.changes
        now = DateTime.utc_now()
        expire_on = DateTime.add(now, changes.duration_mins * 60 - 5, :second)
        extend_expiration(changes.customer, expire_on)
    end
  end

  def delete_user_group(customer_ids) do
    Radusergroup.delete_user_group(customer_ids)
  end

  def get_customer_ids(sessions) do
    Enum.map(sessions, & &1.customer)
  end

  def check_session_exists(customer) do
    case sessions(customer) do
      {:ok, []} ->
        :ok

      {:ok, [_ | _]} ->
        {:error, :session_exists}
    end
  end

  def sessions(customer) do
    query = from(r in Radcheck, where: r.customer == ^customer)
    {:ok, Repo.all(query)}
  end

  defp extend_expiration(customer, new_expire_on) do
    query =
      from(r in Radcheck,
        where: r.customer == ^customer
      )

    case Repo.update_all(query, set: [expire_on: new_expire_on]) do
      {0, _} -> {:error, :customer_session_not_found}
      {_, _} -> {:ok, :ok}
    end
  end
end
