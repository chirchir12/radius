defmodule RadiusWeb.PolicyController do
  use RadiusWeb, :controller

  alias Radius.Policies

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
    with {:ok, :ok} <- Policies.add(:ppp, params) do
      render(conn, "show_ppp.json", ppp: %{status: :ok})
    end
  end

  def update_ppoe(conn, %{"plan" => plan, "policy" => params}) do
    params = Map.put(params, "plan", plan)

    with {:ok, :ok} <- Policies.update(:ppp, params) do
      render(conn, "show_ppp.json", ppp: %{status: :ok})
    end
  end

  def delete_ppoe(conn, %{"plan" => plan}) do
    with {:ok, :ok} <- Policies.delete(:ppp, plan) do
      render(conn, "show_ppp.json", ppp: %{status: :ok})
    end
  end
end
