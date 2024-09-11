defmodule Radius.Repo.Migrations.CreateRadgroupcheckTable do
  use Ecto.Migration

  def change do
    create table(:radgroupcheck) do
      add :groupname, :string, null: false
      add :attribute, :string, null: false
      add :op, :string, size: 2, null: false
      add :value, :string, null: false
      add :plan, :uuid, null: false
    end

    create index(:radgroupcheck, [:groupname])
    create index(:radgroupcheck, [:plan])
  end
end
