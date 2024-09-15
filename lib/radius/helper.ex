defmodule Radius.Helper do
  alias Radius.Auth.Radcheck

  def format_data(data) when is_list(data) do
    Enum.map(data, &format_data/1)
  end

  def format_data(%Radcheck{} = data) do
    %{
      username: data.username,
      customer: data.customer,
      service: data.service
    }
  end

  def encode_data(data) do
    Jason.encode!(data)
  end
end
