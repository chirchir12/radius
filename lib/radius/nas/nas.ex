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
             :company_id,
             :uuid
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
    field :company_id, Ecto.UUID
    field :uuid, Ecto.UUID
  end

  def changeset(nas, attrs) do
    nas
    |> cast(attrs, [
      :id,
      :nasname,
      :shortname,
      :type,
      :ports,
      :secret,
      :server,
      :community,
      :description,
      :company_id,
      :uuid
    ])
    |> validate_required([:nasname, :shortname, :type, :secret, :company_id])
    |> unique_constraint(:id, name: "nas_pkey")
    |> generate_uuid()
  end

  defp generate_uuid(changeset) do
    case get_field(changeset, :uuid) do
      nil -> put_change(changeset, :uuid, Ecto.UUID.generate())
      _ -> changeset
    end
  end
end
