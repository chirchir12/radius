defmodule Radius.Auth.SessionDelete do
  @moduledoc """
  DELETE EXPIRED SESSION/SUBSCRIPTION AND NOTIFY AIRLINK SERVICE
  """
  use Oban.Worker, queue: :clear_individual_internet_sessions, max_attempts: 5

  alias Radius.Sessions
  import Radius.Helper
  alias Radius.RmqPublisher
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"service_type" => service_type, "customer" => customer_id}}) do
    service_type
    |> run_task(customer_id)
  end

  defp run_task("hotspot", customer_id) do
    queue = System.get_env("RMQ_HOTSPOT_SUBSCRIPTION_QUEUE") || "rmq_hotspot_subscription_queue"

    case Sessions.fetch_expired_session(customer_id, "hotspot") do
      {:ok, sessions} ->
        Logger.info("Pruning Hotspot Sessions for #{customer_id}")

        sessions
        |> format_session_data("session_expired")
        |> RmqPublisher.publish(queue)

      {:error, :no_session_to_delete} ->
        Logger.warning("No expired hotspot sessions to delete for customer #{customer_id}")
        :ok
    end
  end

  defp run_task("ppoe", customer_id) do
    queue = System.get_env("RMQ_PPOE_SUBSCRIPTION_QUEUE") || "rmq_ppoe_subscription_queue"

    case Sessions.fetch_expired_session(customer_id, "ppoe") do
      {:ok, sessions} ->
        Logger.info("Pruning PPOE Sessions for #{customer_id}")

        sessions
        |> Enum.uniq_by(& &1.customer)
        |> format_session_data("session_expired")
        |> RmqPublisher.publish(queue)

      {:error, :no_session_to_delete} ->
        Logger.warning("No expired ppoe sessions to delete for customer #{customer_id}")
        :ok
    end
  end

end