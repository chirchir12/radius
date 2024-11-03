defmodule Radius.Auth.SessionDeleteAll do
  use Oban.Worker, queue: :clear_all_internet_sessions, max_attempts: 5

  import Radius.Helper
  alias Radius.Sessions
  alias Radius.Hotspot, as: HotspotPub
  alias Radius.Ppoe, as: PpoePub
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{
        queue: "clear_all_internet_sessions",
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
    |> format_session_data("hotspot_session_expired", "hotspot")
    |> HotspotPub.session_expired()

    sessions
  end

  def publish_to_ppoe(sessions) do
    sessions
    |> get_ppoe_sessions()
    |> Enum.uniq_by(& &1.customer)
    |> format_session_data("ppoe_session_expired", "ppoe")
    |> PpoePub.session_expired()
  end
end
