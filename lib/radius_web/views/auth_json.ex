defmodule RadiusWeb.AuthJSON do
  def render("hotspot.json", %{hotspot: hotspot}) do
    %{
      data: %{
        username: hotspot.username,
        password: hotspot.password,
        plan: hotspot.plan,
        customer: hotspot.customer,
        expire_on: hotspot.expire_on,
        priority: hotspot.priority,
        service: hotspot.service,
        duration_mins: hotspot.duration_mins
      }
    }
  end

  def render("ppp.json", %{ppp: ppp}) do
    %{
      data: %{
        username: ppp.username,
        password: ppp.password,
        profile: ppp.profile,
        customer: ppp.customer,
        expire_on: ppp.expire_on,
        duration_mins: ppp.duration_mins,
        service: ppp.service
      }
    }
  end
end
