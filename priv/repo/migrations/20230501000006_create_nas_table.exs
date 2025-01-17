defmodule Radius.Repo.Migrations.CreateNasTable do
  use Ecto.Migration

  def change do
    create table(:nas) do
      add :nasname, :text, null: false
      add :shortname, :text, null: false
      add :type, :text, null: false, default: "other"
      add :ports, :integer
      add :secret, :text, null: false
      add :server, :text
      add :community, :text
      add :description, :text
      add :company_id, :uuid, null: false
      add :uuid, :uuid, null: false
    end

    create index(:nas, [:nasname])
    create index(:nas, [:company_id])
    create index(:nas, [:uuid])
  end
end
