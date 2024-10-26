defmodule Radius.Repo.Migrations.CreateRadpostauthTable do
  use Ecto.Migration

  def change do
    create table(:radpostauth) do
      add :username, :text, null: false
      add :pass, :text
      add :reply, :text
      add :calledstationid, :text
      add :callingstationid, :text
      add :authdate, :utc_datetime, null: false, default: fragment("NOW()")
    end
  end
end
