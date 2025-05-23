defmodule Radius.Helper do
  alias Radius.Auth.Radcheck

  def format_session_data(data, action, service_type) when is_list(data) do
    Enum.map(data, &format_session_data(&1, action, service_type))
  end

  def format_session_data(%Radcheck{} = data, action, "hotspot") do
    %{
      customer_id: data.customer,
      action: action,
      service: "hotspot",
      sender: :radius
    }
  end

  def format_session_data(%Radcheck{} = data, action, "ppoe") do
    %{
      subscription_uuid: data.customer,
      action: action,
      service: "ppoe",
      sender: :radius
    }
  end

  def encode_data(data) do
    Jason.encode!(data)
  end

  def kw_to_map(data) when is_list(data) do
    if Keyword.keyword?(data) do
      data
      |> Enum.map(fn
        {key, value} when is_list(value) -> {key, kw_to_map(value)}
        {key, value} -> {key, value}
        other -> other
      end)
      |> Enum.into(%{})
    else
      data
    end
  end

  def kw_to_map(data), do: data

  def atomize_map_keys(data) when is_list(data) do
    data
    |> Enum.map(&atomize_map_keys/1)
  end

  def atomize_map_keys(map) when is_map(map) do
    map
    |> Enum.map(fn {k, v} -> {atomize_key(k), atomize_value(v)} end)
    |> Enum.into(%{})
  end

  def process_message(params, func) when is_list(params) do
    params
    |> Enum.map(&atomize_map_keys/1)
    |> Enum.each(&process_message(&1, func))
  end

  def process_message(%{sender: "radius"}, _func) do
    :ok
  end

  def process_message(params, func) when is_function(func, 1) do
    func.(params)
  end

  def update_status(last_seen, type, offline_after \\ 1)

  def update_status(last_seen, :devices, offline_after) do
    current_time = DateTime.utc_now()
    last_seen = get_last_seen(last_seen)

    cond do
      last_seen == nil ->
        "inactive"

      DateTime.diff(current_time, last_seen) > offline_after * 60 ->
        "inactive"

      true ->
        "active"
    end
  end

  defp get_last_seen(last_seen) do
    case last_seen do
      %NaiveDateTime{} ->
        {:ok, datetime} = DateTime.from_naive(last_seen, "Etc/UTC")
        datetime

      %DateTime{} ->
        last_seen

      _ ->
        nil
    end
  end

  defp atomize_key(key) when is_binary(key), do: String.to_atom(key)
  defp atomize_key(key) when is_atom(key), do: key

  defp atomize_value(value) when is_map(value), do: atomize_map_keys(value)
  defp atomize_value(value) when is_list(value), do: Enum.map(value, &atomize_value/1)
  defp atomize_value(value), do: value
end
