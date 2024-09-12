defmodule Radius.Group.Radgroupcheck do
  use Ecto.Schema
  import Ecto.Changeset
  alias Radius.Repo
  import Ecto.Query, warn: false

  schema "radgroupcheck" do
    field :groupname, :string
    field :attribute, :string
    field :op, :string
    field :value, :string
    field :plan, Ecto.UUID
  end

  def update_radgroupcheck(%__MODULE__{} = radgroupcheck, attrs) do
    radgroupcheck
    |> changeset(attrs)
    |> Repo.update()
  end

  def get_by(plan) do
    query = from(r in __MODULE__, where: r.plan == ^plan)
    {:ok, Repo.all(query)}
  end

  def changeset(radgroupcheck, attrs) do
    radgroupcheck
    |> cast(attrs, [:groupname, :attribute, :op, :value, :plan])
    |> validate_required([:groupname, :attribute, :op, :value, :plan])
    |> validate_length(:op, is: 2)
  end
end
