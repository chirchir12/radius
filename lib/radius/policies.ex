defmodule Radius.Policies do
  alias Radius.Policy.{Hotspot, Ppoe}

  def add(:hotspot, attrs) do
    data = hotspot_policy(attrs)
    Hotspot.add_policies(data)
  end

  def add(:ppp, attrs) do
    data = ppoe_policy(attrs)
    Ppoe.add_policies(data)
  end

  def update(:hotspot, attrs) do
    data = hotspot_policy(attrs)
    Hotspot.update_policies(data)
  end

  def update(:ppp, attrs) do
    data = ppoe_policy(attrs)
    Ppoe.update_policies(data)
  end

  def delete(:hotspot, attrs) do
    Hotspot.delete_policies(attrs.plan)
  end

  def delete(:ppp, attrs) do
    Ppoe.delete_policies(attrs.plan)
  end

  defp hotspot_policy(attrs) do
    %Hotspot{
      plan: attrs.plan,
      upload: attrs.upload,
      download: attrs.download,
      duration: attrs.duration
    }
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
end
