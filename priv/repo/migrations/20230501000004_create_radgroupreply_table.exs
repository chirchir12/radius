defmodule Radius.Repo.Migrations.CreateRadgroupreplyTable do
  use Ecto.Migration

  def change do
    create table(:radgroupreply) do
      add :groupname, :string, null: false
      add :attribute, :string, null: false
      add :op, :string, size: 2, null: false
      add :value, :string, null: false
    end

    create index(:radgroupreply, [:groupname])
  end
end
