defmodule Radius.Workers.ScheduleSessionPruner do
  use Oban.Worker, queue: :prune_sessions_per_customer, max_attempts: 5, unique: [period: 60]

  alias Radius.Auth.Hotspot
  import Radius.Helper
  alias Radius.Rmq.SessionPublisher
  require Logger


  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"service_type" => "hotspot", "customer" => customer_id}}) do
    with {:ok, sessions} <- Hotspot.expired_session(customer_id) do
      Logger.info("Pruning Hotspot Sessions for #{customer_id}")
      sessions
      |> format_data()
      |> encode_data()
      |> SessionPublisher.publish("hotspot")
    end
  end



  def enqueue(customer, prune_after, service_type) do
    Logger.info("Scheduling #{service_type} Sessions for #{customer}")
    %{customer: customer, prune_after: prune_after, service_type: service_type}
    |> __MODULE__.new(schedule_in: prune_after)
    |> Oban.insert()
  end
end
