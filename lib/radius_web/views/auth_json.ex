defmodule RadiusWeb.AuthJSON do
  def render("hotspot.json", %{hotspot: hotspot}) do
    %{data: %{
      username: hotspot.username,
      password: hotspot.password,
      plan: hotspot.plan,
      customer: hotspot.customer,
      expire_on: hotspot.expire_on,
      priority: hotspot.priority
    }}
  end

end
