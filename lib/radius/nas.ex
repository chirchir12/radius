defmodule Radius.Nas do
  alias Radius.Repo
  import Ecto.Query, warn: false
  alias Radius.Nas.Router

  def list_routers(company_id) when is_integer(company_id) do
    {:ok, Repo.all(from r in Router, where: r.companyid == ^company_id)}
  end

  def list_routers(company) do
    {:ok, Repo.all(from r in Router, where: r.company == ^company)}
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

  def get_by_uid(uid) do
    case Repo.get_by(Router, uid: uid) do
      nil -> {:error, :router_not_found}
      router -> {:ok, router}
    end
  end

  def create_router(attrs) do
    %Router{}
    |> Router.changeset(attrs)
    |> Repo.insert()
  end

  def update_router(%Router{} = router, attrs) do
    router
    |> Router.changeset(attrs)
    |> Repo.update()
  end

  def delete_router(%Router{} = router), do: Repo.delete(router)

  defp is_uuid?(string) do
    case Ecto.UUID.cast(string) do
      {:ok, _} -> true
      _ -> false
    end
  end
end
