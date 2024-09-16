defmodule RadiusWeb.AuthController do
  use RadiusWeb, :controller

  alias Radius.{Auth, Auth.Hotspot}

  action_fallback RadiusWeb.FallbackController

  def hotspot_login(conn, %{"auth" => params}) do
    with {:ok, %Hotspot{} = data} <- Auth.login(:hotspot, params) do
      conn
      |> put_status(:ok)
      |> render("hotspot.json", hotspot: data)
    end
  end

  def ppp_login(conn, %{"auth" => params}) do
    with {:ok, :ok} <- Auth.login(:ppp, params) do
      conn
      |> put_status(:ok)
      |> json(%{status: :ok})
    end
  end

  def ppp_logout(conn, %{"customer" => customer}) do
    with {:ok, :ok} <- Auth.logout(:ppp, customer) do
      conn
      |> put_status(:ok)
      |> json(%{status: :ok})
    end
  end

  def hotspot_logout(conn, %{"customer" => customer}) do
    with {:ok, :ok} <- Auth.logout(:hotspot, customer) do
      conn
      |> put_status(:ok)
      |> json(%{status: :ok})
    end
  end

  def extend_session(conn, %{"auth" => params}) do
    with {:ok, :ok} <- Auth.extend_session(params) do
      conn
      |> put_status(:ok)
      |> json(%{status: :ok})
    end
  end

  # def clear_session(conn, _params) do
  #   Auth.clear_session()

  #   conn
  #   |> put_status(:ok)
  #   |> json(%{status: :ok})
  # end
end
