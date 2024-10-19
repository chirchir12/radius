defmodule RadiusWeb.IsSystemPlug do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _) do
    conn
    |> assign(:is_system, true)
  end
end
