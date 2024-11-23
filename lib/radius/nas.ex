defmodule Radius.Nas do
  alias Radius.Repo
  import Ecto.Query, warn: false
  alias Radius.Nas.Router
  alias Radius.RmqPublisher

  def list_routers(company_id) do
    query = from r in Router, where: r.company_id == ^company_id, order_by: [desc: r.id]
    {:ok, Repo.all(query)}
  end

  def list_routers do
    {:ok, Repo.all(Router)}
  end

  def get_router(id) do
    case is_uuid?(id) do
      true -> get_by_uid(id)
      false -> get_by_id(id)
    end
  end

  def get_by_id(id) when is_integer(id) do
    case Repo.get_by(Router, id: id) do
      nil -> {:error, :router_not_found}
      router -> {:ok, router}
    end
  end

  def get_by_id(id) do
    case Repo.get_by(Router, id: String.to_integer(id)) do
      nil -> {:error, :router_not_found}
      router -> {:ok, router}
    end
  end

  def get_by_uid(uuid) do
    case Repo.get_by(Router, uuid: uuid) do
      nil -> {:error, :router_not_found}
      router -> {:ok, router}
    end
  end

  def create_router(attrs) do
    %Router{}
    |> Router.changeset(attrs)
    |> Repo.insert()
    |> handle_router_response("create")
  end

  def update_router(%Router{} = router, attrs) do
    router
    |> Router.changeset(attrs)
    |> Repo.update()
    |> handle_router_response("update")
  end

  def delete_router(%Router{} = router) do
    Repo.delete(router)
    |> handle_router_response("delete")
  end

  defp is_uuid?(string) do
    case Ecto.UUID.cast(string) do
      {:ok, _} -> true
      _ -> false
    end
  end

  defp handle_router_response({:ok, router}, action) do
    :ok = maybe_publish_to_rmq(router, action)
    {:ok, router}
  end

  defp handle_router_response({:error, error}, _action) do
    {:error, error}
  end

  defp maybe_publish_to_rmq(%Router{} = router, action) do
    queue = System.get_env("RMQ_ROUTER_ROUTING_KEY") || "router_changes_rk"

    data =
      %{
        router_id: router.uuid,
        nasname: router.nasname,
        shortname: router.shortname,
        type: router.type,
        ports: router.ports,
        secret: router.secret,
        server: router.server,
        community: router.community,
        description: router.description,
        company_id: router.company_id,
        uuid: router.uuid,
        action: action,
        sender: :radius
      }

    {:ok, _} = RmqPublisher.publish(data, queue)
    :ok
  end
end
