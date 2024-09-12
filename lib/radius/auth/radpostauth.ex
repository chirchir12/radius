defmodule Radius.Auth.Radpostauth do
  use Ecto.Schema

  @primary_key {:id, :id, autogenerate: true}
  schema "radpostauth" do
    field :username, :string
    field :pass, :string
    field :reply, :string
    field :called_station_id, :string
    field :calling_station_id, :string
    field :authdate, :utc_datetime
  end
end
