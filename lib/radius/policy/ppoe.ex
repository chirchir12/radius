defmodule Radius.Policy.Ppoe do
  alias Radius.Group.{Radgroupcheck, Radgroupreply}
  alias Radius.UserGroup.Radusergroup
  alias Radius.Repo
  import Ecto.Query

  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :pool, :string
    field :plan, Ecto.UUID
    field :profile, :string
    field :upload, :integer
    field :download, :integer
    field :duration, :integer
    field :priority, :integer, default: 0
  end

  def changeset(ppoe, attrs) do
    ppoe
    |> cast(attrs, [:pool, :plan, :profile, :upload, :download, :duration, :priority])
    |> validate_required([:pool, :plan, :profile, :upload, :download, :duration])
    |> validate_number(:upload, greater_than: 0)
    |> validate_number(:download, greater_than: 0)
    |> validate_number(:duration, greater_than: 0)
    |> validate_number(:priority, greater_than_or_equal_to: 0)
  end

  def add_policies(%__MODULE__{} = attrs) do
    with {:ok, _} <- add_group_check_policy(attrs),
         {:ok, _} <- add_user_group(attrs),
         {:ok, _} <- add_group_reply_policy(attrs) do
      {:ok, :ok}
    end
  end

  def update_policies(%__MODULE__{} = attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:update_group_check, fn repo, _ ->
      update_group_check_policy(repo, attrs)
    end)
    |> Ecto.Multi.run(:update_user_group, fn repo, _ ->
      update_user_group(repo, attrs)
    end)
    |> Ecto.Multi.run(:update_group_reply, fn repo, _ ->
      update_group_reply_policy(repo, attrs)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        {:ok, :ok}

      {:error, failed_operation, failed_value, _changes_so_far} ->
        {:error, {failed_operation, failed_value}}
    end
  end

  def delete_policies(plan) do
    result =
      Repo.transaction(fn ->
        Repo.delete_all(from(c in Radgroupcheck, where: c.plan == ^plan))
        Repo.delete_all(from(u in Radusergroup, where: u.groupname == ^plan))
        Repo.delete_all(from(r in Radgroupreply, where: r.groupname == ^plan))
      end)

    case result do
      {:ok, _} -> {:ok, :ok}
      {:error, error} -> {:error, error}
    end
  end

  defp add_group_check_policy(%__MODULE__{} = attrs) do
    policy = %{
      groupname: attrs.plan,
      attribute: "Framed-Protocol",
      op: "==",
      value: "PPP",
      plan: attrs.plan
    }

    Radgroupcheck.changeset(%Radgroupcheck{}, policy)
    |> Repo.insert()
  end

  defp add_user_group(%__MODULE__{} = attrs) do
    user_group = %{
      username: attrs.plan,
      groupname: attrs.plan,
      plan: attrs.plan,
      priority: attrs.priority,
      service: "ppoe"
    }

    Radusergroup.changeset(%Radusergroup{}, user_group)
    |> Repo.insert()
  end

  defp add_group_reply_policy(%__MODULE__{} = attrs) do
    bandwidth = %{
      groupname: attrs.plan,
      attribute: "Mikrotik-Rate-Limit",
      op: "=",
      value: "#{attrs.upload}M/#{attrs.download}M"
    }

    session_timeout = %{
      groupname: attrs.plan,
      attribute: "Session-Timeout",
      op: "=",
      value: "#{attrs.duration}"
    }

    pool = %{
      groupname: attrs.plan,
      attribute: "Framed-Pool",
      op: "=",
      value: attrs.pool
    }

    bandwidth = Radgroupreply.changeset(%Radgroupreply{}, bandwidth)
    session_timeout = Radgroupreply.changeset(%Radgroupreply{}, session_timeout)
    pool = Radgroupreply.changeset(%Radgroupreply{}, pool)

    if bandwidth.valid? and session_timeout.valid? and pool.valid? do
      valid_bandwidth = bandwidth.changes
      valid_session_timeout = session_timeout.changes
      valid_pool = pool.changes

      case Repo.insert_all(Radgroupreply, [valid_bandwidth, valid_session_timeout, valid_pool]) do
        {3, nil} ->
          {:ok, :ok}

        {_, _errors} ->
          {:error, %{bandwidth: bandwidth, session_timeout: session_timeout, pool: pool}}
      end
    else
      {:error, %{bandwidth: bandwidth, session_timeout: session_timeout, pool: pool}}
    end
  end

  # Helper functions for each update operation
  defp update_group_check_policy(repo, %{plan: plan}) do
    from(c in Radgroupcheck, where: c.plan == ^plan)
    |> repo.update_all(
      set: [groupname: plan, attribute: "Framed-Protocol", op: "==", value: "PPP"]
    )
    |> case do
      {n, nil} when is_integer(n) -> {:ok, n}
      _ -> {:error, "Failed to update group check policy"}
    end
  end

  defp update_user_group(repo, %{plan: plan, priority: priority}) do
    from(u in Radusergroup, where: u.groupname == ^plan)
    |> repo.update_all(set: [username: plan, groupname: plan, priority: priority])
    |> case do
      {n, nil} when is_integer(n) -> {:ok, n}
      _ -> {:error, "Failed to update user group"}
    end
  end

  defp update_group_reply_policy(repo, %{
         plan: plan,
         upload: upload,
         download: download,
         duration: duration,
         pool: pool
       }) do
    updates = [
      {Radgroupreply,
       [
         groupname: plan,
         attribute: "Mikrotik-Rate-Limit",
         op: "=",
         value: "#{upload}M/#{download}M"
       ]},
      {Radgroupreply,
       [groupname: plan, attribute: "Session-Timeout", op: "=", value: "#{duration}"]},
      {Radgroupreply, [groupname: plan, attribute: "Framed-Pool", op: "=", value: pool]}
    ]

    results =
      Enum.map(updates, fn {schema, set_attrs} ->
        from(r in schema, where: r.groupname == ^plan and r.attribute == ^set_attrs[:attribute])
        |> repo.update_all(set: set_attrs)
      end)

    if Enum.all?(results, fn {n, nil} -> is_integer(n) end) do
      {:ok, Enum.sum(Enum.map(results, fn {n, _} -> n end))}
    else
      {:error, "Failed to update group reply policy"}
    end
  end
end
