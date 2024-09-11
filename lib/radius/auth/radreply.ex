defmodule Radius.Auth.Radreply do
  use Ecto.Schema
  import Ecto.Changeset

  schema "radreply" do
    field :username, :string
    field :attribute, :string
    field :op, :string, default: "="
    field :value, :string
    field :companyid, :integer, default: nil
  end

  def changeset(radreply, attrs) do
    radreply
    |> cast(attrs, [:username, :attribute, :op, :value, :companyid])
    |> validate_required([:username, :attribute, :op, :value, :companyid])
    |> validate_length(:op, is: 2)
  end
end
