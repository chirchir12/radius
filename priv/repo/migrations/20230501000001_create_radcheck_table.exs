defmodule Radius.Repo.Migrations.CreateRadcheckTable do
  use Ecto.Migration

  def change do
    create table(:radcheck) do
      add :username, :string, null: false
      add :attribute, :string, null: false
      add :op, :string, size: 2, null: false
      add :value, :string, null: false
      add :companyid, :bigint, null: false
    end

    create index(:radcheck, [:username])
    create index(:radcheck, [:companyid])
  end
end
