defmodule Radius.Auth do
  import Ecto.Query, warn: false
  alias Radius.Auth.{Hotspot, Ppoe}
  alias Radius.TaskSchedular
  alias Radius.Sessions
  alias Radius.Hotspot, as: HotspotPub
  alias Radius.Ppoe, as: PpoePub
  require Logger

  def login(:hotspot, attrs) do
    with {:ok, data} <- validate_login(%Hotspot{}, attrs),
         :ok <- Sessions.check_session_exists(data.customer),
         {:ok, %Hotspot{} = data} <- Hotspot.login(data),
         {:ok, %Oban.Job{}} <-
           TaskSchedular.schedule(data.customer, data.duration_mins, :hotspot) do
      :ok = HotspotPub.session_activated(data, "hotspot_session_activated")
      {:ok, data}
    end
  end

  def login(:ppoe, attrs) do
    with {:ok, data} <- validate_login(%Ppoe{}, attrs),
         :ok <- Sessions.check_session_exists(data.customer),
         {:ok, %Ppoe{} = data} <- Ppoe.login(data),
         {:ok, %Oban.Job{}} <-
           TaskSchedular.schedule(data.subscription_uuid, data.duration_mins, :ppoe) do
      :ok = PpoePub.session_activated(data, "ppoe_session_activated")
      {:ok, data}
    end
  end

  def logout(:hotspot, customer) do
    Hotspot.logout(customer)
  end

  def logout(:ppoe, subscription_uuid) do
    Ppoe.logout(subscription_uuid)
  end

  def extend_session(%{
        "service" => service,
        "customer" => customer,
        "duration_mins" => duration_mins
      })
      when service in ["hotspot", "ppoe"] do
    with {:ok, :ok} <- Sessions.extend_session(customer, duration_mins, service) do
      TaskSchedular.schedule(customer, duration_mins, String.to_atom(service))
      {:ok, :ok}
    end
  end

  def extend_session(_attrs) do
    {:error, :invalid_service}
  end

  defp validate_login(%Hotspot{} = hotspot, attrs) do
    changeset = Hotspot.changeset(hotspot, attrs)

    case changeset.valid? do
      false ->
        {:error, changeset}

      true ->
        changes = changeset.changes
        now = DateTime.utc_now()
        # -5 seconds to avoid race condition
        expires_on =
          case Map.get(changes, :expires_on) do
            nil ->
              DateTime.add(now, changes.duration_mins * 60 - 5, :second)

            _ ->
              Map.get(changes, :expires_on)
          end

        duration_in_mins =
          case Map.get(changes, :expires_on) do
            nil ->
              changes.duration_mins

            _ ->
              DateTime.diff(expires_on, now, :second) |> div(60)
          end

        data = %{
          hotspot
          | username: changes.username,
            password: changes.password,
            customer: changes.customer,
            service: "hotspot",
            expire_on: expires_on,
            plan: changes.plan,
            priority: Map.get(changes, :priority, 10),
            duration_mins: duration_in_mins
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
        now = DateTime.utc_now()

        expires_on =
          case Map.get(changes, :expires_on) do
            nil ->
              DateTime.add(now, changes.duration_mins * 60 - 5, :second)

            _ ->
              Map.get(changes, :expires_on)
          end

        duration_in_mins =
          case Map.get(changes, :expires_on) do
            nil ->
              changes.duration_mins

            _ ->
              DateTime.diff(expires_on, now, :second) |> div(60)
          end

        data = %{
          ppoe
          | username: changes.username,
            password: changes.password,
            subscription_uuid: changes.subscription_uuid,
            service: "ppoe",
            expire_on: expires_on,
            plan: changes.plan,
            duration_mins: duration_in_mins
        }

        {:ok, data}
    end
  end
end
