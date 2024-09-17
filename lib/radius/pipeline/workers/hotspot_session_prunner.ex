defmodule Radius.Pipeline.Workers.HotspotSessionPruner do
  use Oban.Worker, queue: :prune_hotspot_sessions, max_attempts: 5

  alias Radius.Auth
  import Radius.Helper
  alias Radius.Rmq.SessionPublisher
  require Logger


  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"service_type" => "hotspot", "customer" => customer_id}}) do
    with {:ok, sessions} <- Auth.fetch_expired_session(customer_id, "hotspot") do
      Logger.info("Pruning Hotspot Sessions for #{customer_id}")
      sessions
      |> format_data()
      |> encode_data()
      |> SessionPublisher.publish("hotspot")
    end
  end

  def perform(_job) do
    Logger.warning("Invalid Job Args")
    :ok
  end
end
