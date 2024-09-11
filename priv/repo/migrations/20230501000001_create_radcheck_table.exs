defmodule Radius.Repo.Migrations.CreateRadcheckTable do
  use Ecto.Migration

  def change do
    create table(:radcheck) do
      add :username, :string, null: false
      add :attribute, :string, null: false
      add :op, :string, size: 2, null: false
      add :value, :string, null: false
      add :customer, :uuid
      add :expire_on, :utc_datetime, null: false
    end

    create index(:radcheck, [:username])
    create index(:radcheck, [:customer])
  end
end
