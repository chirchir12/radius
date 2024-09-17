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



  def publish(encoded_data, service_type) when is_binary(encoded_data) and byte_size(encoded_data) > 0 do
    queue = get_queue(service_type)
    case GenRMQ.Publisher.publish(__MODULE__, encoded_data, queue) do
      :ok ->
        Logger.info("Published #{service_type} message to #{queue}")
        {:ok, :ok}

      {:ok, :confirmed} ->
        {:ok, :ok}

      {:error, reason} ->
        Logger.error("Error publishing #{service_type} message to #{queue}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def publish(_, service_type, _queue) do
    {:error, "Invalid  #{service_type} data"}
  end

  def get_queue(service_type) do
    Application.get_env(:radius, Radius.Rmq.SessionPublisher)[:"#{service_type}_sessions_queue"]
  end
end
