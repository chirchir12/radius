defmodule Radius.Pipeline.Workers.HotspotSessionPruner do
  use Oban.Worker, queue: :prune_hotspot_sessions, max_attempts: 5

  alias Radius.Sessions
  import Radius.Helper
  alias Radius.Rmq.SessionPublisher
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"service_type" => "hotspot", "customer" => customer_id}}) do
    case Sessions.fetch_expired_session(customer_id, "hotspot") do
      {:ok, sessions} ->
        Logger.info("Pruning Hotspot Sessions for #{customer_id}")

        sessions
        |> format_data()
        |> encode_data()
        |> SessionPublisher.publish("hotspot")

      {:error, :no_session_to_delete} ->
        Logger.warning("No expired sessions to delete for customer #{customer_id}")
        :ok
    end
  end
end
