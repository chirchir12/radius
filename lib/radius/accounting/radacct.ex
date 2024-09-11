defmodule Radius.Accounting.Radacct do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:radacctid, :id, autogenerate: true}
  schema "radacct" do
    field :acctsessionid, :string
    field :acctuniqueid, :string
    field :username, :string
    field :realm, :string
    field :nasipaddress, :string
    field :nasportid, :string
    field :nasporttype, :string
    field :acctstarttime, :utc_datetime
    field :acctupdatetime, :utc_datetime
    field :acctstoptime, :utc_datetime
    field :acctinterval, :integer
    field :acctsessiontime, :integer
    field :acctauthentic, :string
    field :connectinfo_start, :string
    field :connectinfo_stop, :string
    field :acctinputoctets, :integer
    field :acctoutputoctets, :integer
    field :calledstationid, :string
    field :callingstationid, :string
    field :acctterminatecause, :string
    field :servicetype, :string
    field :framedprotocol, :string
    field :framedipaddress, :string
  end

  def changeset(radacct, attrs) do
    radacct
    |> cast(attrs, [:acctsessionid, :acctuniqueid, :username, :realm, :nasipaddress, :nasportid, :nasporttype, :acctstarttime, :acctupdatetime, :acctstoptime, :acctinterval, :acctsessiontime, :acctauthentic, :connectinfo_start, :connectinfo_stop, :acctinputoctets, :acctoutputoctets, :calledstationid, :callingstationid, :acctterminatecause, :servicetype, :framedprotocol, :framedipaddress])
    |> validate_required([:acctsessionid, :acctuniqueid, :nasipaddress])
  end
end
