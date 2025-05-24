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
             :uuid,
             :last_seen
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
    # validate ipv4
    field :vpn_ip, :string
    field :company_id, Ecto.UUID
    field :uuid, Ecto.UUID
    field :last_seen, :utc_datetime
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
      :company_id,
      :uuid,
      :last_seen,
      :vpn_ip
    ])
    |> validate_required([:nasname, :shortname, :type, :secret, :company_id])
    |> unique_constraint(:id, name: "nas_pkey")
    |> generate_uuid()
  end

  def update_accounting_changeset(router, attrs) do
    router
    |> cast(attrs, [:last_seen, :nasname])
    |> validate_required([:last_seen, :nasname])
  end

  defp generate_uuid(changeset) do
    case get_field(changeset, :uuid) do
      nil -> put_change(changeset, :uuid, Ecto.UUID.generate())
      _ -> changeset
    end
  end
end
