defmodule Radius.Auth.Radcheck do
  use Ecto.Schema
  import Ecto.Changeset

  schema "radcheck" do
    field :username, :string
    field :attribute, :string
    field :op, :string
    field :value, :string
    field :companyid, :integer, default: nil
  end

  def changeset(radcheck, attrs) do
    radcheck
    |> cast(attrs, [:username, :attribute, :op, :value, :companyid])
    |> validate_required([:username, :attribute, :op, :value, :companyid])
  end
end
