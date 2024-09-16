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

  def render("ppoe.json", %{ppoe: ppoe}) do
    %{
      data: %{
        username: ppoe.username,
        password: ppoe.password,
        profile: ppoe.profile,
        customer: ppoe.customer,
        expire_on: ppoe.expire_on,
        duration_mins: ppoe.duration_mins,
        service: ppoe.service
      }
    }
  end
end
