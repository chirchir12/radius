defmodule Radius.Auth.Radreply do
  use Ecto.Schema
  import Ecto.Changeset

  schema "radreply" do
    field :username, :string
    field :attribute, :string
    field :op, :string, default: "="
    field :value, :string
    field :customer, Ecto.UUID
    field :service, :string, virtual: true
  end

  def changeset(radreply, attrs) do
    radreply
    |> cast(attrs, [:username, :attribute, :op, :value, :customer, :service])
    |> validate_required([:username, :attribute, :op, :value, :service])
    |> validate_service()
    |> validate_length(:op, is: 2)
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
