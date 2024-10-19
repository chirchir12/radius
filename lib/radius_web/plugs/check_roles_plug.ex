defmodule RadiusWeb.CheckRolesPlug do
  import Phoenix.Controller
  import Plug.Conn

  def init(roles), do: roles

  def call(%Plug.Conn{assigns: %{roles: user_roles}} = conn, roles) do
    if(Enum.any?(roles, &(&1 in user_roles))) do
      conn
    else
      handle_error(conn)
    end
  end

  def call(conn, _roles) do
    handle_error(conn)
  end

  defp handle_error(conn) do
    conn
        |> put_status(:forbidden)
        |> put_view(json: RadiusWeb.ErrorJSON)
        |> render(:"403",
          error: %{
            status: :forbidden,
            reason: "Resource forbidden, not enough roles"
          }
        )
        |> halt()
  end

end
