defmodule RadiusWeb.PolicyJSON do
  def render("show_hotspot.json", %{hotspot: hotspot}) do
    %{data: hotspot}
  end

  def render("show_ppoe.json", %{ppoe: ppoe}) do
    %{data: ppoe}
  end
end
