defmodule Radius.UserGroup.Radusergroup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "radusergroup" do
    field :username, :string
    field :groupname, :string
    field :priority, :integer, default: 0
    field :customer, Ecto.UUID
    field :service, :string, virtual: true
  end

  def changeset(radusergroup, attrs) do
    radusergroup
    |> cast(attrs, [:username, :groupname, :priority, :customer, :service])
    |> validate_required([:username, :groupname, :service])
    |> validate_service()
  end

  defp validate_service(changeset) do
    case get_field(changeset, :service) do
      "hotspot" ->
        validate_required(changeset, [:customer])
      "ppp" ->
        put_change(changeset, :customer, nil)
      nil ->
        add_error(changeset, :service, "must be either 'ppp' or 'hotspot'")
      _ ->
        add_error(changeset, :service, "must be either 'ppp' or 'hotspot'")
    end
  end
end
