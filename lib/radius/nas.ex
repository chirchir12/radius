defmodule Radius.Nas do
  alias Radius.Repo
  import Ecto.Query, warn: false
  alias Radius.Nas.Router

  def list_routers(company_id) do
    {:ok, Repo.all(from r in Router, where: r.companyid == ^company_id)}
  end

  def list_routers do
    {:ok, Repo.all(Router)}
  end

  def get_router(id) do
    case Repo.get(Router, id) do
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
end
