defmodule Radius.Helper do
  alias Radius.Auth.Radcheck

  def format_session_data(data, action) when is_list(data) do
    Enum.map(data, &format_session_data(&1, action))
  end

  def format_session_data(%Radcheck{} = data, action) do
    %{
      customer_id: data.customer,
      action: action
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
end
