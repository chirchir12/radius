defmodule RadiusWeb.AuthController do
  use RadiusWeb, :controller

  alias Radius.{Auth, Auth.Hotspot, Auth.Ppoe}

  action_fallback RadiusWeb.FallbackController

  def hotspot_login(conn, %{"auth" => params}) do
    with {:ok, %Hotspot{} = data} <- Auth.login(:hotspot, params) do
      conn
      |> put_status(:ok)
      |> render("hotspot.json", hotspot: data)
    end
  end

  def ppoe_login(conn, %{"auth" => params}) do
    with {:ok, %Ppoe{} = data} <- Auth.login(:ppoe, params) do
      conn
      |> put_status(:ok)
      |> render("ppoe.json", ppoe: data)
    end
  end

  def ppoe_logout(conn, %{"customer" => customer}) do
    with {:ok, :ok} <- Auth.logout(:ppoe, customer) do
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
end
