defmodule RadiusWeb.PolicyJSON do
  def render("show_hotspot.json", %{hotspot: hotspot}) do
    %{data: hotspot}
  end

  def render("show_ppp.json", %{ppp: ppp}) do
    %{data: ppp}
  end
end
