defmodule Radius.Pipeline.Workers.SessionPrunner do
  use Oban.Worker, queue: :prune_all_expired_sessions, max_attempts: 5
  alias Radius.Auth
  import Radius.Helper
  alias Radius.Rmq.SessionPublisher
  require Logger


  @impl Oban.Worker
  def perform(%Oban.Job{queue: "prune_all_expired_sessions"} = job) do
    Logger.info("Pruning All Sessions")
    IO.inspect(job)
    with {:ok, sessions} <- Auth.fetch_expired_session(),
    {:ok, _} <- publish_to_hotspot(sessions),
    {:ok, _} <- publish_to_ppoe(sessions) do
      :ok
    end
  end


  defp get_hotspot_sessions(sessions) do
    sessions
    |> Enum.filter(fn session -> session.service == "hotspot" end)
  end

  defp get_ppoe_sessions(sessions) do
    sessions
    |> Enum.filter(fn session -> session.service == "ppoe" end)
  end

  defp publish_to_hotspot(sessions) do
    sessions
    |> get_hotspot_sessions()
    |> format_data()
    |> encode_data()
    |> SessionPublisher.publish("hotspot")
  end

  defp publish_to_ppoe(sessions) do
    sessions
    |> get_ppoe_sessions()
    |> format_data()
    |> encode_data()
    |> SessionPublisher.publish("ppoe")
  end

end
