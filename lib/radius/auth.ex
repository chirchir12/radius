defmodule Radius.Auth do
  import Ecto.Query, warn: false
  alias Radius.Repo
  alias Radius.Auth.{Hotspot, Ppoe, Radcheck}

  def login(:hotspot, attrs) do
    data = %Hotspot{
      username: attrs.username,
      password: attrs.password,
      customer: attrs.customer,
      service: "hotspot",
      expire_on: attrs.expire_on,
      plan: attrs.plan,
      priority: attrs.priority,
    }
    Hotspot.login(data)
  end

  def login(:ppp, attrs) do
    data = %Ppoe{
      username: attrs.username,
      password: attrs.password,
      customer: attrs.customer,
      service: "ppp",
      expire_on: attrs.expire_on,
      profile: attrs.profile,
    }
    Ppoe.login(data)
  end

  def logout(:hotspot, customer) do
    Hotspot.logout(customer)
  end

  def logout(:ppp, customer) do
    Ppoe.logout(customer)
  end

  def clear_session() do
    now = DateTime.utc_now()
    query = from(r in Radcheck, where: r.expire_on < ^now)
    Repo.delete_all(query)
  end
end
