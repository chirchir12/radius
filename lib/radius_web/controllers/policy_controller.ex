defmodule RadiusWeb.PolicyController do
  use RadiusWeb, :controller

  alias Radius.Policies

  plug RadiusWeb.CheckRolesPlug, ["%", "admin"]
  action_fallback RadiusWeb.FallbackController

  # Hotspot actions
  def create_hotspot(conn, %{"policy" => params}) do
    with {:ok, :ok} <- Policies.add(:hotspot, params) do
      conn
      |> put_status(:created)
      |> render("show_hotspot.json", hotspot: %{status: :ok})
    end
  end

  def update_hotspot(conn, %{"plan" => plan, "policy" => params}) do
    params = Map.put(params, "plan", plan)

    with {:ok, :ok} <- Policies.update(:hotspot, params) do
      render(conn, "show_hotspot.json", hotspot: %{status: :ok})
    end
  end

  def delete_hotspot(conn, %{"plan" => plan}) do
    with {:ok, :ok} <- Policies.delete(:hotspot, plan) do
      render(conn, "show_hotspot.json", hotspot: %{status: :ok})
    end
  end

  # PPPoE actions
  def create_ppoe(conn, %{"policy" => params}) do
    with {:ok, :ok} <- Policies.add(:ppoe, params) do
      render(conn, "show_ppoe.json", ppoe: %{status: :ok})
    end
  end

  def update_ppoe(conn, %{"plan" => plan, "policy" => params}) do
    params = Map.put(params, "plan", plan)

    with {:ok, :ok} <- Policies.update(:ppoe, params) do
      render(conn, "show_ppoe.json", ppoe: %{status: :ok})
    end
  end

  def delete_ppoe(conn, %{"plan" => plan}) do
    with {:ok, :ok} <- Policies.delete(:ppoe, plan) do
      render(conn, "show_ppoe.json", ppoe: %{status: :ok})
    end
  end
end
