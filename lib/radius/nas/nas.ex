defmodule Radius.NAS.Nas do
  use Ecto.Schema
  import Ecto.Changeset

  schema "nas" do
    field :nasname, :string
    field :shortname, :string
    field :type, :string
    field :ports, :integer
    field :secret, :string
    field :server, :string
    field :community, :string
    field :description, :string
    field :companyid, :integer, default: nil
  end

  def changeset(nas, attrs) do
    nas
    |> cast(attrs, [:nasname, :shortname, :type, :ports, :secret, :server, :community, :description, :companyid])
    |> validate_required([:nasname, :shortname, :type, :secret, :companyid])
  end
end
