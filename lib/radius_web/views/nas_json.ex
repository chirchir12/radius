defmodule RadiusWeb.NasJSON do
  def render("index.json", %{routers: routers}) do
    %{data: routers}
  end

  def render("show_router.json", %{router: router}) do
    %{data: router}
  end
end
