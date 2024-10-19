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
end
