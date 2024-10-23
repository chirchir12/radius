defmodule Radius.Auth do
  import Ecto.Query, warn: false
  alias Radius.Auth.{Hotspot, Ppoe}
  alias Radius.TaskSchedular
  alias Radius.Sessions
  alias Radius.RmqPublisher
  require Logger

  def login(:hotspot, attrs) do
    with {:ok, data} <- validate_login(%Hotspot{}, attrs),
         :ok <- Sessions.check_session_exists(data.customer),
         {:ok, %Hotspot{} = data} <- Hotspot.login(data),
         {:ok, %Oban.Job{}} <-
          TaskSchedular.schedule(data.customer, data.duration_mins, :hotspot) do
      :ok = maybe_publish_to_rmq(data, "session_activated", "hotspot")
      {:ok, data}
    end
  end

  def login(:ppoe, attrs) do
    with {:ok, data} <- validate_login(%Ppoe{}, attrs),
         :ok <- Sessions.check_session_exists(data.customer),
         {:ok, %Ppoe{} = data} <- Ppoe.login(data),
         {:ok, %Oban.Job{}} <- TaskSchedular.schedule(data.customer, data.duration_mins, :ppoe) do
      {:ok, data}
    end
  end

  def logout(:hotspot, customer) do
    Hotspot.logout(customer)
  end

  def logout(:ppoe, customer) do
    Ppoe.logout(customer)
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
        expire_on = DateTime.add(now, changes.duration_mins * 60 - 5, :second)

        data = %{
          hotspot
          | username: changes.username,
            password: changes.password,
            customer: changes.customer,
            service: "hotspot",
            expire_on: expire_on,
            plan: changes.plan,
            priority: Map.get(changes, :priority, 10),
            duration_mins: changes.duration_mins
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
        # -5 seconds to avoid race condition
        expire_on = DateTime.add(now, changes.duration_mins * 60 - 5, :second)

        data = %{
          ppoe
          | username: changes.username,
            password: changes.password,
            customer: changes.customer,
            service: "ppoe",
            expire_on: expire_on,
            profile: changes.profile,
            duration_mins: changes.duration_mins
        }

        {:ok, data}
    end
  end

  defp maybe_publish_to_rmq(data, action, service) when service == "hotspot" do
    queue = System.get_env("RMQ_SUBSCRIPTION_QUEUE") || "rmq_subscription_queue"

    data = %{
      action: action,
      expires_at: data.expire_on,
      customer_id: data.customer,
      plan_id: data.plan,
      service: "hotspot"
    }

    {:ok, _} = RmqPublisher.publish(data, queue)
    Logger.info("Published #{action} to #{queue}")
    :ok
  end

  def handle_auth_change(%{service: service} = params) when service in ["hotspot", "ppoe"] do
    handle_auth(service, params )
  end

  def handle_auth_change(params) do
    :ok = Logger.error("could not start session for customer: #{inspect(params)}")
    :ok
  end

  def handle_auth(service, %{action: "session_activate"} = params) do
    login(String.to_atom(service), params )
  end

end
