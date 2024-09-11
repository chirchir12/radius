defmodule Radius.Group.Radgroupcheck do
  use Ecto.Schema
  import Ecto.Changeset

  schema "radgroupcheck" do
    field :groupname, :string
    field :attribute, :string
    field :op, :string
    field :value, :string
    field :plan, Ecto.UUID
  end

  def changeset(radgroupcheck, attrs) do
    radgroupcheck
    |> cast(attrs, [:groupname, :attribute, :op, :value, :plan])
    |> validate_required([:groupname, :attribute, :op, :value, :plan])
    |> validate_length(:op, is: 2)
  end
end
