defmodule Radius.Auth.SessionDelete do
  @moduledoc """
  DELETE EXPIRED SESSION/SUBSCRIPTION AND NOTIFY AIRLINK SERVICE
  """
  use Oban.Worker, queue: :clear_individual_internet_sessions, max_attempts: 5

  alias Radius.Sessions
  import Radius.Helper
  alias Radius.Hotspot, as: HotspotPub
  alias Radius.Ppoe, as: PpoePub
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"service_type" => service_type, "customer" => customer_id}}) do
    Logger.info("Deleting Individual internet session sessions")
    service_type
    |> run_task(customer_id)
  end

  defp run_task("hotspot", customer_id) do
    case Sessions.fetch_expired_session(customer_id, "hotspot") do
      {:ok, sessions} ->
        Logger.info("Pruning Hotspot Sessions for #{customer_id}")

        sessions
        |> format_session_data("hotspot_session_expired", "hotspot")
        |> HotspotPub.session_expired()

      {:error, :no_session_to_delete} ->
        Logger.warning("No expired hotspot sessions to delete for customer #{customer_id}")
        :ok
      {:error, error} ->
        Logger.error("Failed to prune session for customer #{customer_id} - Error #{error}")
        :error
    end
  end

  defp run_task("ppoe", customer_id) do
    case Sessions.fetch_expired_session(customer_id, "ppoe") do
      {:ok, sessions} ->
        Logger.info("Pruning PPOE Sessions for #{customer_id}")

        sessions
        |> Enum.uniq_by(& &1.customer)
        |> format_session_data("ppoe_session_expired", "ppoe")
        |> PpoePub.session_expired()

      {:error, :no_session_to_delete} ->
        Logger.warning("No expired ppoe sessions to delete for customer #{customer_id}")
        :ok
    end
  end
end
