defmodule Radius.Pipeline.Workers.PpoeSessionPruner do
  use Oban.Worker, queue: :prune_ppoe_sessions, max_attempts: 5

  alias Radius.Sessions
  import Radius.Helper
  alias Radius.Rmq.SessionPublisher
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"service_type" => "ppoe", "customer" => customer_id}}) do
    case Sessions.fetch_expired_session(customer_id, "ppoe") do
      {:ok, sessions} ->
        Logger.info("Pruning PPOE Sessions for #{customer_id}")

        sessions
        |> format_data()
        |> encode_data()
        |> SessionPublisher.publish("ppoe")

      {:error, :no_session_to_delete} ->
        Logger.warning("No expired sessions to delete for customer #{customer_id}")
        :ok
    end
  end
end
