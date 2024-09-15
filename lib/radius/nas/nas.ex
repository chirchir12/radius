defmodule Radius.Nas.Router do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [
             :id,
             :nasname,
             :shortname,
             :type,
             :ports,
             :secret,
             :server,
             :community,
             :description,
             :companyid,
             :uid
           ]}
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
    field :uid, Ecto.UUID
  end

  def changeset(nas, attrs) do
    nas
    |> cast(attrs, [
      :nasname,
      :shortname,
      :type,
      :ports,
      :secret,
      :server,
      :community,
      :description,
      :companyid,
      :uid
    ])
    |> validate_required([:nasname, :shortname, :type, :secret, :companyid])
    |> generate_uuid()
  end

  defp generate_uuid(changeset) do
    case get_field(changeset, :uid) do
      nil -> put_change(changeset, :uid, Ecto.UUID.generate())
      _ -> changeset
    end
  end
end
