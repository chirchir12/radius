defmodule RadiusWeb.NasController do
  use RadiusWeb, :controller

  alias Radius.Nas
  plug RadiusWeb.CheckRolesPlug, ["%", "admin", "system"]

  action_fallback RadiusWeb.FallbackController

  def index(conn, %{"company" => company}) do
    if is_uuid?(company) do
      with {:ok, routers} <- Nas.list_routers(company) do
        render(conn, :index, routers: routers)
      end
    else
      with {:ok, routers} <- Nas.list_routers(String.to_integer(company)) do
        render(conn, :index, routers: routers)
      end
    end
  end

  def index(conn, _params) do
    with {:ok, routers} <- Nas.list_routers() do
      render(conn, :index, routers: routers)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, router} <- Nas.get_router(id) do
      render(conn, :show, router: router)
    end
  end

  def create(conn, %{"params" => router_params}) do
    with {:ok, router} <- Nas.create_router(router_params) do
      conn
      |> put_status(:created)
      |> render(:show, router: router)
    end
  end

  def update(conn, %{"id" => id, "params" => router_params}) do
    with {:ok, router} <- Nas.get_router(id),
         {:ok, updated_router} <- Nas.update_router(router, router_params) do
      render(conn, :show, router: updated_router)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, router} <- Nas.get_router(id),
         {:ok, deleted_router} <- Nas.delete_router(router) do
      render(conn, :show, router: deleted_router)
    end
  end

  defp is_uuid?(string) do
    case Ecto.UUID.cast(string) do
      {:ok, _} -> true
      _ -> false
    end
  end
end
