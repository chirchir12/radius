defmodule Radius.Repo.Migrations.CreateRadreplyTable do
  use Ecto.Migration

  def change do
    create table(:radreply) do
      add :username, :string, null: false
      add :attribute, :string, null: false
      add :op, :string, size: 2, null: false
      add :value, :string, null: false
      add :customer, :uuid
    end

    create index(:radreply, [:username])
    create index(:radreply, [:customer])
  end
end
