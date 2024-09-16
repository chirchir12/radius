defmodule Radius.Rmq.SessionPublisher do
  @behaviour GenRMQ.Publisher
  require Logger

  def start_link() do
    GenRMQ.Publisher.start_link(__MODULE__, name: __MODULE__)
  end

  def init() do
    config = Application.get_env(:radius, __MODULE__)
    [
      exchange: config[:exchange],
      uri: config[:url],
      durable: true
    ]
  end

  def publish_session(data, key) do
    case GenRMQ.Publisher.publish(__MODULE__, data, key) do
      :ok ->
        {:ok, :ok}
      {:ok, :confirmed} ->
        {:ok, :ok}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
