defmodule Radius.Repo.Migrations.CreateRadacctTable do
  use Ecto.Migration

  def change do
    create table(:radacct, primary_key: false) do
      add :radacctid, :bigserial, primary_key: true
      add :acctsessionid, :text, null: false
      add :acctuniqueid, :text, null: false
      add :username, :text
      add :realm, :text
      add :nasipaddress, :inet, null: false
      add :nasportid, :text
      add :nasporttype, :text
      add :acctstarttime, :utc_datetime
      add :acctupdatetime, :utc_datetime
      add :acctstoptime, :utc_datetime
      add :acctinterval, :bigint
      add :acctsessiontime, :bigint
      add :acctauthentic, :text
      add :connectinfo_start, :text
      add :connectinfo_stop, :text
      add :acctinputoctets, :bigint
      add :acctoutputoctets, :bigint
      add :calledstationid, :text
      add :callingstationid, :text
      add :acctterminatecause, :text
      add :servicetype, :text
      add :framedprotocol, :text
      add :framedipaddress, :inet
    end

    create unique_index(:radacct, [:acctuniqueid])

    create index(:radacct, [:acctuniqueid],
             where: "acct_stop_time IS NULL",
             name: :radacct_active_session_idx
           )

    create index(:radacct, [:nasipaddress, :acctstarttime],
             where: "acct_stop_time IS NULL",
             name: :radacct_bulk_close
           )

    create index(:radacct, [:acctstarttime, :username], name: :radacct_start_user_idx)
  end
end
