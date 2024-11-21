defmodule RadiusWeb.AccountingController do
  use RadiusWeb, :controller

  def create(conn, params) do
    IO.inspect(conn, label: "conn")
    IO.inspect(params, label: "params")
    conn |> json(%{})
  end
end
