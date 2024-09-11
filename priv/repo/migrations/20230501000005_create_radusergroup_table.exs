defmodule Radius.Repo.Migrations.CreateRadusergroupTable do
  use Ecto.Migration

  def change do
    create table(:radusergroup) do
      add :username, :string, null: false
      add :groupname, :string, null: false
      add :priority, :integer
      add :customer, :uuid
    end

    create index(:radusergroup, [:username])
    create index(:radusergroup, [:groupname])
    create index(:radusergroup, [:customer])
  end
end
