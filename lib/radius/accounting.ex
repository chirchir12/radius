defmodule Radius.Accounting do
  alias Radius.RmqPublisher

  def publish(%{"framed_protocol" => "PPP"} = params) do
    # these are ppp account data
    params = Map.put_new(params, "sender", :radius)
    routing_key = System.get_env("RMQ_PPPOE_ACCOUNTING_KEY") || "ppoe_accounting_rk"
    RmqPublisher.publish(params, routing_key)
  end

  def publish(params) do
    # these are hotspot accounting data
    params = Map.put_new(params, "sender", :radius)
    routing_key = System.get_env("RMQ_HOTSPOT_ACCOUNTING_KEY") || "hotspot_accounting_rk"
    RmqPublisher.publish(params, routing_key)
  end
end
