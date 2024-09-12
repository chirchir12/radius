defmodule Radius.Repo.Migrations.CreateRadacctTable do
  use Ecto.Migration

  def change do
    create table(:radacct, primary_key: false) do
      add :radacct_id, :bigserial, primary_key: true
      add :acct_session_id, :text, null: false
      add :acct_unique_id, :text, null: false
      add :username, :text
      add :realm, :text
      add :nas_ip_address, :inet, null: false
      add :nas_port_id, :text
      add :nas_port_type, :text
      add :acct_start_time, :utc_datetime
      add :acct_update_time, :utc_datetime
      add :acct_stop_time, :utc_datetime
      add :acct_interval, :bigint
      add :acct_session_time, :bigint
      add :acct_authentic, :text
      add :connect_info_start, :text
      add :connect_info_stop, :text
      add :acct_input_octets, :bigint
      add :acct_output_octets, :bigint
      add :called_station_id, :text
      add :calling_station_id, :text
      add :acct_terminate_cause, :text
      add :service_type, :text
      add :framed_protocol, :text
      add :framed_ip_address, :inet
    end

    create unique_index(:radacct, [:acct_unique_id])

    create index(:radacct, [:acct_unique_id],
             where: "acct_stop_time IS NULL",
             name: :radacct_active_session_idx
           )

    create index(:radacct, [:nas_ip_address, :acct_start_time],
             where: "acct_stop_time IS NULL",
             name: :radacct_bulk_close
           )

    create index(:radacct, [:acct_start_time, :username], name: :radacct_start_user_idx)
  end
end
