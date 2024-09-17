defmodule Radius.Pipeline.Workers.SessionPrunner do
  use Oban.Worker, queue: :prune_all_expired_sessions, max_attempts: 5

  import Radius.Helper
  alias Radius.Sessions
  alias Radius.Rmq.SessionPublisher
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{
        queue: "prune_all_expired_sessions",
        args: %{"check_after_in_mins" => in_mins}
      }) do
    Logger.info("Pruning All dead sessions")

    case Sessions.fetch_expired_sessions_after(in_mins) do
      {:ok, sessions} ->
        publish_to_hotspot(sessions)
        |> Sessions.get_customer_ids()
        |> Sessions.delete_user_group()

        publish_to_ppoe(sessions)
        :ok

      {:error, :no_session_to_delete} ->
        Logger.warning("No dead sessions to delete")
        :ok
    end
  end

  def get_hotspot_sessions(sessions) do
    sessions
    |> Enum.filter(fn session -> session.service == "hotspot" end)
  end

  def get_ppoe_sessions(sessions) do
    sessions
    |> Enum.filter(fn session -> session.service == "ppoe" end)
  end

  def publish_to_hotspot(sessions) do
    sessions
    |> get_hotspot_sessions()
    |> Enum.uniq_by(& &1.customer)
    |> format_data()
    |> encode_data()
    |> SessionPublisher.publish("hotspot")

    sessions
  end

  def publish_to_ppoe(sessions) do
    sessions
    |> get_ppoe_sessions()
    |> Enum.uniq_by(& &1.customer)
    |> format_data()
    |> encode_data()
    |> SessionPublisher.publish("ppoe")
  end
end
