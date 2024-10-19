defmodule RadiusWeb.EnsureAuthenticatedPlug do
  import Plug.Conn
  alias Radius.Diralink.Auth
  import Phoenix.Controller
  import Radius.Helper

  def init(default), do: default

  def call(%Plug.Conn{assigns: %{is_system: true}} = conn, _) do
    check_auth(conn, true)
  end

  def call(conn, _) do
    check_auth(conn, false)
  end

  defp check_auth(conn, is_system) do
    with {:ok, token_data} <- get_header(conn, "authorization"),
         {:ok, token} <- get_token(token_data),
         {:ok, claims} <- Auth.decode_token(token, is_system) do
      %{roles: roles} = claims |> atomize_map_keys()

      conn
      |> assign(:roles, roles)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> put_view(json: RadiusWeb.ErrorJSON)
        |> render(:"401", error: %{detail: :unauthorized})
        |> halt()
    end
  end

  defp get_header(conn, header) do
    case get_req_header(conn, header) do
      [value | _] -> {:ok, value}
      _ -> :error
    end
  end

  defp get_token("Bearer " <> token) do
    {:ok, token}
  end

  defp get_token(_) do
    {:error, :missing_token}
  end
end
