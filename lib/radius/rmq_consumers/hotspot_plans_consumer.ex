defmodule Radius.RmqConsumers.HotspotsPlansConsumer do
  @behaviour GenRMQ.Consumer
  alias GenRMQ.Message
  require Logger
  alias Radius.Policies
  import Radius.Helper

  def start_link() do
    GenRMQ.Consumer.start_link(__MODULE__, name: __MODULE__)
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    }
  end

  def ack(%Message{attributes: %{delivery_tag: tag}} = message) do
    Logger.debug("Message successfully processed. Tag: #{tag}")
    GenRMQ.Consumer.ack(message)
  end

  def reject(%Message{attributes: %{delivery_tag: tag}} = message, requeue \\ true) do
    Logger.info("Rejecting message, tag: #{tag}, requeue: #{requeue}")
    GenRMQ.Consumer.reject(message, requeue)
  end

  @impl GenRMQ.Consumer
  def init() do
    options = get_options()
    options
  end

  @impl GenRMQ.Consumer
  def handle_message(%Message{payload: payload} = message) do
    Logger.info("Received message: #{inspect(message)}")
    payload = Jason.decode!(payload) |> atomize_map_keys()

    with :ok <- Policies.handle_policy_changes(:hotspot, payload) do
      ack(message)
    end
  end

  @impl GenRMQ.Consumer
  def handle_error(%Message{attributes: attributes, payload: payload} = message, reason) do
    Logger.error(
      "Rejecting message due to consumer task error: #{inspect(reason: reason, msg_attributes: attributes, msg_payload: payload)}"
    )

    GenRMQ.Consumer.reject(message, false)
  end

  @impl GenRMQ.Consumer
  def consumer_tag() do
    {:ok, hostname} = :inet.gethostname()
    "#{hostname}-hotspot-plans-consumer"
  end

  defp get_options() do
    :radius
    |> Application.get_env(__MODULE__)
  end

end
