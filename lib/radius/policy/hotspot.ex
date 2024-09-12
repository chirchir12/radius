defmodule Radius.Policy.Hotspot do
  alias Radius.Group.{Radgroupcheck, Radgroupreply}
  alias Radius.Repo
  alias Ecto.Multi
  import Ecto.Query

  defstruct plan: nil, upload: nil, download: nil, duration: nil

  def add_policies(%__MODULE__{} = attrs) do
    with {:ok, :ok} <- add_group_check_policy(attrs),
         {:ok, :ok} <- add_group_reply_policy(attrs) do
      {:ok, :ok}
    else
      {:error, errors} ->
        {:error, errors}
    end
  end

  def update_policies(%__MODULE__{} = attrs) do
    replies = Repo.all(from r in Radgroupreply, where: r.groupname == ^attrs.plan)
    checks = Repo.all(from c in Radgroupcheck, where: c.groupname == ^attrs.plan)

    multi =
      Enum.reduce(replies ++ checks, Multi.new(), fn policy, multi ->
        changes =
          case {policy.__struct__, policy.attribute} do
            {Radgroupreply, "Mikrotik-Rate-Limit"} ->
              %{value: "#{attrs.upload}/M#{attrs.download}/M"}

            {Radgroupreply, "Session-Timeout"} ->
              %{value: attrs.duration}

            {Radgroupcheck, "Session-Timeout"} ->
              %{value: attrs.duration}

            {Radgroupcheck, "Mikrotik-Rate-Limit"} ->
              %{value: "#{attrs.upload}/M#{attrs.download}/M"}

            _ ->
              %{}
          end

        Multi.update(
          multi,
          {:update, policy.__struct__, policy.id},
          policy.__struct__.changeset(policy, changes)
        )
      end)

    case Repo.transaction(multi) do
      {:ok, _results} ->
        {:ok, :ok}

      {:error, failed_operation, failed_value, _changes_so_far} ->
        {:error, {failed_operation, failed_value}}
    end
  end

  def delete_policies(plan) do
    multi =
      Multi.new()
      |> Multi.delete_all(:delete_checks, from(c in Radgroupcheck, where: c.groupname == ^plan))
      |> Multi.delete_all(:delete_replies, from(r in Radgroupreply, where: r.groupname == ^plan))

    case Repo.transaction(multi) do
      {:ok, _} ->
        {:ok, :ok}

      {:error, failed_operation, failed_value, _changes_so_far} ->
        {:error, {failed_operation, failed_value}}
    end
  end

  defp add_group_check_policy(%__MODULE__{} = attrs) do
    bandwidth = %{
      groupname: attrs.plan,
      attribute: "Mikrotik-Rate-Limit",
      op: ":=",
      value: "#{attrs.upload}/M#{attrs.download}/M",
      plan: attrs.plan
    }

    session_timeout = %{
      groupname: attrs.plan,
      attribute: "Session-Timeout",
      op: ":=",
      value: attrs.duration,
      plan: attrs.plan
    }

    bandwidth = Radgroupcheck.changeset(%Radgroupcheck{}, bandwidth)
    session_timeout = Radgroupcheck.changeset(%Radgroupcheck{}, session_timeout)

    if bandwidth.valid? and session_timeout.valid? do
      valid_bandwidth = bandwidth.changes
      valid_session_timeout = session_timeout.changes

      case Repo.insert_all(Radgroupcheck, [valid_bandwidth, valid_session_timeout]) do
        {2, nil} ->
          {:ok, :ok}

        {_, _errors} ->
          {:error, %{bandwidth: bandwidth, session_timeout: session_timeout}}
      end
    else
      {:error, %{bandwidth: bandwidth, session_timeout: session_timeout}}
    end
  end

  defp add_group_reply_policy(%__MODULE__{} = attrs) do
    bandwidth = %{
      groupname: attrs.plan,
      attribute: "Mikrotik-Rate-Limit",
      op: ":=",
      value: "#{attrs.upload}/M#{attrs.download}/M"
    }

    session_timeout = %{
      groupname: attrs.plan,
      attribute: "Session-Timeout",
      op: ":=",
      value: attrs.duration
    }

    bandwidth = Radgroupreply.changeset(%Radgroupreply{}, bandwidth)
    session_timeout = Radgroupreply.changeset(%Radgroupreply{}, session_timeout)

    if bandwidth.valid? and session_timeout.valid? do
      valid_bandwidth = bandwidth.changes
      valid_session_timeout = session_timeout.changes

      case Repo.insert_all(Radgroupreply, [valid_bandwidth, valid_session_timeout]) do
        {2, nil} ->
          {:ok, :ok}

        {_, _errors} ->
          {:error, %{bandwidth: bandwidth, session_timeout: session_timeout}}
      end
    else
      {:error, %{bandwidth: bandwidth, session_timeout: session_timeout}}
    end
  end
end
