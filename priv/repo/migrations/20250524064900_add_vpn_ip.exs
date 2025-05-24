defmodule Radius.Repo.Migrations.AddVpnIp do
  use Ecto.Migration

  def change do
    alter table(:nas) do
      add :vpn_ip, :string
    end

    create unique_index(:nas, [:vpn_ip])
  end
end
