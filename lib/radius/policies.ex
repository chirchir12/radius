defmodule Radius.Policies do
  alias Radius.Policy.{Hotspot, Ppoe}
  alias Radius.Group.Radgroupreply
  import Ecto.Query
  alias Radius.Repo

  def add_policy(:hotspot, attrs) do
    with {:ok, %Hotspot{} = data} <- hotspot_policy(attrs),
         :ok <- check_policy_exists(data.plan),
         {:ok, :ok} <- Hotspot.add_policies(data) do
      {:ok, :ok}
    end
  end

  def add_policy(:ppoe, attrs) do
    with {:ok, %Ppoe{} = data} <- ppoe_policy(attrs),
         :ok <- check_policy_exists(data.plan),
         {:ok, :ok} <- Ppoe.add_policies(data) do
      {:ok, :ok}
    end
  end

  def update_policy(:hotspot, attrs) do
    with {:ok, %Hotspot{} = data} <- hotspot_policy(attrs),
         {:ok, :ok} <- Hotspot.update_policies(data) do
      {:ok, :ok}
    end
  end

  def update_policy(:ppoe, attrs) do
    with {:ok, %Ppoe{} = data} <- ppoe_policy(attrs),
         {:ok, :ok} <- Ppoe.update_policies(data) do
      {:ok, :ok}
    end
  end

  def delete_policy(:hotspot, plan) do
    with {:ok, :ok} <- Hotspot.delete_policies(plan) do
      {:ok, :ok}
    end
  end

  def delete_policy(:ppoe, plan) do
    with {:ok, :ok} <- Ppoe.delete_policies(plan) do
      {:ok, :ok}
    end
  end

  defp hotspot_policy(attrs) do
    hotspot = %Hotspot{}
    changeset = Hotspot.changeset(%Hotspot{}, attrs)

    case changeset.valid? do
      true ->
        valid_changes = changeset.changes

        data = %{
          hotspot
          | plan: valid_changes.plan,
            upload: valid_changes.upload,
            download: valid_changes.download,
            duration: valid_changes.duration
        }

        {:ok, data}

      false ->
        {:error, changeset}
    end
  end

  defp ppoe_policy(attrs) do
    ppoe = %Ppoe{}
    changeset = Ppoe.changeset(%Ppoe{}, attrs)

    case changeset.valid? do
      true ->
        valid_changes = changeset.changes

        data = %{
          ppoe
          | plan: valid_changes.plan,
            upload: valid_changes.upload,
            download: valid_changes.download,
            duration: valid_changes.duration,
            priority: Map.get(valid_changes, :priority, 0),
            pool: valid_changes.pool,
            profile: valid_changes.profile
        }

        {:ok, data}

      false ->
        {:error, changeset}
    end
  end

  defp policy_exists?(plan) do
    {:ok, policies} = get_policies(plan)

    case policies do
      [] ->
        false

      [_ | _] ->
        true
    end
  end

  defp check_policy_exists(plan) do
    case policy_exists?(plan) do
      true ->
        {:error, :policy_exists}

      false ->
        :ok
    end
  end

  defp get_policies(plan) do
    query =
      from(r in Radgroupreply,
        where: r.groupname == ^plan,
        select: [:value]
      )

    {:ok, Repo.all(query)}
  end

  def handle_policy_changes(type, params) do
    handle_change(type, params)
  end

  defp handle_change(type, %{action: "create"} = params) do
    {:ok, _policy} = add_policy(type, params)
    :ok
  end

  defp handle_change(type, %{action: "update"} = params) do
    {:ok, _policy} = update_policy(type, params)
    :ok
  end

  defp handle_change(type, %{action: "delete", plan: plan}) do
    {:ok, _policy} = delete_policy(type, plan)
    :ok
  end
end
