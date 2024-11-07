defmodule Radius.RmqConsumers.PpoeSubscriptionConsumer do
  @behaviour GenRMQ.Consumer
  alias GenRMQ.Message
  require Logger
  alias Radius.Auth
  alias Radius.Auth.Ppoe
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

    with :ok <- process_message(payload, &handle_subscription_change/1) do
      ack(message)
    else
      error ->
        :ok = Logger.error("Failed to process ppoe message: #{inspect(error)}")
        reject(message)
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
    "#{hostname}-radius-ppoe-subscriptions-consumer"
  end

  def handle_subscription_change(%{service: service} = params) when service == "ppoe" do
    handle_subscription(params)
  end

  def handle_subscription_change(params) do
    :ok = Logger.warning("Failed to handle subscriptions: #{inspect(params)}")
    :ok
  end

  def handle_subscription(%{action: "activate_session"} = params) do
    with {:ok, _data} <- Auth.login(:ppoe, params) do
      :ok
    end
  end

  def handle_subscription(%{action: "deactivate_session", customer: customer}) do
    with {:ok, _data} <- Auth.logout(:ppoe, customer) do
      :ok
    end
  end

  def handle_subscription(%{action: "delete_customer", customer: customer}) do
    with {:ok, _data} <- Auth.logout(:ppoe, customer) do
      :ok
    end
  end

  def handle_subscription(%{action: "update_customer_auth"} = params) do
    :ok = Ppoe.update_username_password(params)
    :ok
  end

  def handle_subscription(%{action: "change_customer_plan"} = params) do
    :ok = Ppoe.update_plan(params)
    :ok
  end

  def handle_subscription(_service, _params) do
    :ok
  end

  defp get_options() do
    :radius
    |> Application.get_env(__MODULE__)
  end
end
