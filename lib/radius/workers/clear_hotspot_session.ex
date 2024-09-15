defmodule Radius.Workers.ClearHotspotSession do
  use Oban.Worker, queue: :hotspot_sessions, max_attempts: 5, unique: [period: 60]

  alias Radius.Auth
  import Radius.Helper
  alias Radius.Rmq.SessionPublisher

  @impl Oban.Worker
  def perform(_job) do
    with {:ok, customers} <- Auth.clear_expired_sessions(:hotspot) do
      publish(customers)
    end
  end

  defp publish(data) when is_list(data) and length(data) > 0 do
    SessionPublisher.publish_session(prep_data(data), get_queue())
  end

  defp publish(_) do
    :ok
  end

  defp prep_data(data) do
    data
    |> format_data()
    |> encode_data()
  end

  defp get_queue() do
    Application.get_env(:radius, Radius.Rmq.SessionPublisher)[:hotspot_sessions_queue]
  end
end
