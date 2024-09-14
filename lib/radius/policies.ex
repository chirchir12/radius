defmodule Radius.Policies do
  alias Radius.Policy.{Hotspot, Ppoe}

  def add(:hotspot, attrs) do
    with {:ok, %Hotspot{} = data} <- hotspot_policy(attrs),
         :ok <- check_policy_exists(data.plan),
         {:ok, :ok} <- Hotspot.add_policies(data) do
      {:ok, :ok}
    end
  end

  def add(:ppp, attrs) do
    data = ppoe_policy(attrs)
    Ppoe.add_policies(data)
  end

  def update(:hotspot, attrs) do
    with {:ok, %Hotspot{} = data} <- hotspot_policy(attrs),
         {:ok, :ok} <- Hotspot.update_policies(data) do
      {:ok, :ok}
    end
  end

  def update(:ppp, attrs) do
    data = ppoe_policy(attrs)
    Ppoe.update_policies(data)
  end

  def delete(:hotspot, plan) do
    Hotspot.delete_policies(plan)
  end

  def delete(:ppp, plan) do
    Ppoe.delete_policies(plan)
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
    %Ppoe{
      plan: attrs.plan,
      upload: attrs.upload,
      download: attrs.download,
      duration: attrs.duration,
      priority: attrs.priority,
      pool: attrs.pool,
      profile: attrs.profile
    }
  end

  defp policy_exists?(plan) do
    {:ok, policies} = Hotspot.get_policies(plan)

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
end
