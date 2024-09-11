defmodule Radius.Accounting do
  import Ecto.Query, warn: false
  alias Radius.Repo
  alias Radius.Accounting.Radacct

  def list_radaccts do
    Repo.all(Radacct)
  end

  def get_radacct!(id), do: Repo.get!(Radacct, id)

  def create_radacct(attrs \\ %{}) do
    %Radacct{}
    |> Radacct.changeset(attrs)
    |> Repo.insert()
  end

  def update_radacct(%Radacct{} = radacct, attrs) do
    radacct
    |> Radacct.changeset(attrs)
    |> Repo.update()
  end

  def delete_radacct(%Radacct{} = radacct) do
    Repo.delete(radacct)
  end

  def change_radacct(%Radacct{} = radacct, attrs \\ %{}) do
    Radacct.changeset(radacct, attrs)
  end
end
