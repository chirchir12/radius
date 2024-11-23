defmodule Radius.Repo.Migrations.AddColumnLastSeen do
  use Ecto.Migration

  def change do
    alter table(:nas) do
      add :last_seen, :utc_datetime
    end
  end
end
