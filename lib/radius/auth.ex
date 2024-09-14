defmodule Radius.Auth do
  import Ecto.Query, warn: false
  alias Radius.Repo
  alias Radius.Auth.{Hotspot, Ppoe, Radcheck}

  def login(:hotspot, attrs) do
    with {:ok, data} <- validate_login(%Hotspot{}, attrs) do
      Hotspot.login(data)
    end
  end

  def login(:ppp, attrs) do
    with {:ok, data} <- validate_login(%Ppoe{}, attrs) do
      Ppoe.login(data)
    end
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

  defp validate_login(%Hotspot{} = hotspot, attrs) do
    changeset = Hotspot.changeset(hotspot, attrs)

    case changeset.valid? do
      false ->
        {:error, changeset}

      true ->
        changes = changeset.changes

        data = %{
          hotspot
          | username: changes.username,
            password: changes.password,
            customer: changes.customer,
            service: "hotspot",
            expire_on: changes.expire_on,
            plan: changes.plan,
            priority: Map.get(changes, :priority, 10)
        }

        {:ok, data}
    end
  end

  defp validate_login(%Ppoe{} = ppoe, attrs) do
    changeset = Ppoe.changeset(ppoe, attrs)

    case changeset.valid? do
      false ->
        {:error, changeset}

      true ->
        changes = changeset.changes

        data = %{
          ppoe
          | username: changes.username,
            password: changes.password,
            customer: changes.customer,
            service: "ppp",
            expire_on: changes.expire_on,
            profile: changes.profile
        }

        {:ok, data}
    end
  end
end
