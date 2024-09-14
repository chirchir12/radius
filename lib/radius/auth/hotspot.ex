defmodule Radius.Auth.Hotspot do
  alias Radius.Repo
  alias Radius.Auth.Radcheck
  alias Radius.UserGroup.Radusergroup

  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :username, :string
    field :password, :string
    field :customer, :string
    field :service, :string, default: "hotspot"
    field :expire_on, :naive_datetime
    field :plan, :string
    field :priority, :integer, default: 0
  end

  def changeset(hotspot, attrs) do
    hotspot
    |> cast(attrs, [:username, :password, :customer, :service, :expire_on, :plan, :priority])
    |> validate_required([:username, :password, :customer, :expire_on, :plan])
    |> validate_inclusion(:service, ["hotspot"])
    |> validate_number(:priority, greater_than_or_equal_to: 0)
  end

  def login(%__MODULE__{} = attrs) do
    check = %{
      username: attrs.username,
      attribute: "Cleartext-Password",
      op: "==",
      value: attrs.password,
      customer: attrs.customer,
      service: "hotspot",
      expire_on: attrs.expire_on
    }

    group = %{
      username: attrs.username,
      groupname: attrs.plan,
      customer: attrs.customer,
      service: "hotspot",
      priority: attrs.priority
    }

    case Repo.transaction(fn ->
           with {:ok, %Radcheck{}} <- Radcheck.create_radcheck(check),
                {:ok, %Radusergroup{}} <- Radusergroup.create_radusergroup(group) do
             :ok
           end
         end) do
      {:ok, :ok} -> {:ok, :ok}
      {:ok, {:error, reason}} -> {:error, reason}
      {:error, reason} -> {:error, reason}
    end
  end

  def logout(customer) do
    case Repo.transaction(fn ->
           with {:ok, %Radcheck{} = check_session} <- Radcheck.get_by(customer),
                {:ok, %Radcheck{}} <- Radcheck.delete_radcheck(check_session),
                {:ok, %Radusergroup{} = group_session} <- Radusergroup.get_by(customer),
                {:ok, %Radusergroup{}} <- Radusergroup.delete_radusergroup(group_session) do
             :ok
           end
         end) do
      {:ok, :ok} -> {:ok, :ok}
      {:ok, {:error, reason}} -> {:error, reason}
      {:error, reason} -> {:error, reason}
    end
  end
end
