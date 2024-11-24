defmodule Radius.Accounting do
  alias Radius.RmqPublisher
  alias Radius.Nas
  alias Radius.Repo
  alias Radius.Nas.Router
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

  def update_router(%{"nas_identifier" => nas_identifier, "nas_ip_address" => nas_ip_address}) do
    Task.start(fn ->
      case Nas.get_by_uid(nas_identifier) do
        {:ok, router} ->
          Logger.info("Router found: #{router.id}")
          data = %{last_seen: DateTime.utc_now(), nasname: nas_ip_address}
          Router.update_accounting_changeset(router, data) |> Repo.update()
          :ok

        {:error, _} ->
          Logger.error("Router not found: #{nas_identifier}")
          :ok
      end
    end)
  end
end
