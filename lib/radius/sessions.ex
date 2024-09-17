defmodule Radius.Sessions do
  alias Radius.Auth.Radcheck
  alias Radius.UserGroup.Radusergroup

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

  def delete_user_group(customer_ids) do
    Radusergroup.delete_user_group(customer_ids)
  end

  def get_customer_ids(sessions) do
    Enum.map(sessions, & &1.customer)
  end
end
