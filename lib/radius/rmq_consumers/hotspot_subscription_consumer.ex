defmodule Radius.RmqConsumers.HotspotSubscriptionConsumer do
  @behaviour GenRMQ.Consumer
  alias GenRMQ.Message
  require Logger
  alias Radius.Auth
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
    Logger.info("Message successfully processed. Tag: #{tag}")
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

    with :ok <- process_message(payload, &handle_hotspot_subscription/1) do
      ack(message)
    else
      error ->
        handle_hotspot_error(error, message)
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
    "#{hostname}-radius-hotspot-subscriptions-consumer"
  end

  defp handle_hotspot_subscription(%{service: service} = params) when service == "hotspot" do
    handle_subscription(service, params)
  end

  defp handle_hotspot_subscription(params) do
    :ok = Logger.warning("Failed to handle subscriptions: #{inspect(params)}")
    :ok
  end

  def handle_subscription(service, %{action: "session_activate"} = params) do
    with {:ok, _data} <- Auth.login(String.to_atom(service), params) do
      :ok
    end
  end

  def handle_subscription(service, %{action: "deactivate_session", customer: customer}) do
    with {:ok, _data} <- Auth.logout(String.to_atom(service), customer) do
      :ok
    end
  end

  def handle_subscription(service, %{action: "delete_customer", customer: customer}) do
    with {:ok, _data} <- Auth.logout(String.to_atom(service), customer) do
      :ok
    end
  end

  def handle_subscription(_service, _params) do
    :ok
  end


  defp get_options() do
    :radius
    |> Application.get_env(__MODULE__)
  end

  defp handle_hotspot_error({:error, :session_exists}, message) do
    :ok = Logger.warning("Session exists")
    ack(message)
  end

  defp handle_hotspot_error(error, message) do
    :ok = Logger.error("Failed to process hotspot message: #{inspect(error)}")
    reject(message)
  end
end
