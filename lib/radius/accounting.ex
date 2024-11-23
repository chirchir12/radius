defmodule Radius.Accounting do
  alias Radius.RmqPublisher
  alias Radius.Nas
  require Logger

  def publish(%{"framed_protocol" => "PPP"} = params) do
    # these are ppp account data
    params = Map.put_new(params, "sender", :radius)
    routing_key = System.get_env("RMQ_PPPOE_ACCOUNTING_KEY") || "ppoe_accounting_rk"
    update_router(params)
    RmqPublisher.publish(params, routing_key)
  end

  def publish(params) do
    # these are hotspot accounting data
    params = Map.put_new(params, "sender", :radius)
    routing_key = System.get_env("RMQ_HOTSPOT_ACCOUNTING_KEY") || "hotspot_accounting_rk"
    update_router(params)
    RmqPublisher.publish(params, routing_key)
  end

  def update_router(%{"nas_identifier" => nas_identifier}) do
    Task.start(fn ->
      case Nas.get_by_uid(nas_identifier) do
        {:ok, router} ->
          Logger.info("Router found: #{router.id}")
          Nas.update_router(router, %{last_seen: DateTime.utc_now()})
          :ok

        {:error, _} ->
          Logger.error("Router not found: #{nas_identifier}")
          :ok
      end
    end)
  end
end
