defmodule RadiusWeb.AccountingController do
  use RadiusWeb, :controller

  def create(conn, params) do
    formatted_params = format_params(params)
    IO.inspect(formatted_params, label: "formatted_params")
    conn |> json(%{})
  end

  def format_params(params) do
    Enum.map(params, fn {key, %{"type" => type, "value" => [value]}} ->
      formatted_key = format_key(key)
      formatted_value = format_value(type, value)
      {formatted_key, formatted_value}
    end)
    |> Enum.into(%{})
  end

  defp format_value("integer", value), do: value
  defp format_value("string", value), do: value
  defp format_value("ipaddr", value), do: value
  defp format_value("date", value), do: value
  defp format_value(_, value), do: value

  def format_date(date_string) do
    # Assuming the date format is "Nov 21 2024 09:36:31 UTC"
    # You can parse and format it as needed
    {:ok, datetime, _} = DateTime.from_iso8601(date_string)
    DateTime.to_string(datetime)
  end

  defp format_key(key) do
    key
    |> String.downcase()
    |> String.replace("-", "_")
  end
end
