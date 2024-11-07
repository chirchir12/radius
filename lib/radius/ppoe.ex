defmodule Radius.Ppoe do
  @moduledoc """
  PPoe module to handle all publishing
  """
  alias Radius.RmqPublisher
  require Logger
  alias alias Radius.Auth.Ppoe

  def session_activated(%Ppoe{} = params, action) do
    data = %{
      action: action,
      expires_at: params.expire_on,
      subscription_uuid: params.subscription_uuid,
      plan_id: params.plan,
      service: "ppoe",
      sender: :radius
    }

    publish(data)
  end

  def session_expired(data) do
    publish(data)
  end

  defp publish(data) do
    queue = queue()
    {:ok, _} = RmqPublisher.publish(data, queue)
    Logger.info("Published #{data.action} to #{queue}")
    :ok
  end

  defp queue do
    System.get_env("RMQ_PPOE_SUBSCRIPTION_ROUTING_KEY") || "ppoe_subscription_changes_rk"
  end
end
