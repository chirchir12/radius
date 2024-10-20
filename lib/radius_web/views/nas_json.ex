defmodule RadiusWeb.NasJSON do
  alias Radius.Nas.Router
  def index(%{routers: routers}) do
    %{data: for(router <- routers, do: data(router))}
  end

  def show(%{router: router}) do
    %{data: data(router)}
  end

  defp data(%Router{} = router) do
    %{
      id: router.id,
      nasname: router.nasname,
      shortname: router.shortname,
      type: router.type,
      ports: router.ports,
      secret: router.secret,
      server: router.secret,
      community: router.community,
      description: router.description,
      company_id: router.companyid,
      router_id: router.uuid
    }
  end
end
