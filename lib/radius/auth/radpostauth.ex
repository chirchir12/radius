defmodule Radius.Auth.Radpostauth do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "radpostauth" do
    field :username, :string
    field :pass, :string
    field :reply, :string
    field :called_station_id, :string
    field :calling_station_id, :string
    field :authdate, :utc_datetime
  end

  def changeset(radpostauth, attrs) do
    radpostauth
    |> cast(attrs, [:username, :pass, :reply, :called_station_id, :calling_station_id, :authdate])
    |> validate_required([:username, :authdate])
  end
end
