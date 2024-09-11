defmodule Radius.Group.Radgroupreply do
  use Ecto.Schema
  import Ecto.Changeset

  schema "radgroupreply" do
    field :groupname, :string
    field :attribute, :string
    field :op, :string
    field :value, :string
  end

  def changeset(radgroupreply, attrs) do
    radgroupreply
    |> cast(attrs, [:groupname, :attribute, :op, :value])
    |> validate_required([:groupname, :attribute, :op, :value])
  end
end
