defmodule Radius.UserGroup do
  import Ecto.Query, warn: false
  alias Radius.Repo
  alias Radius.UserGroup.Radusergroup

  def list_radusergroups do
    Repo.all(Radusergroup)
  end

  def get_radusergroup!(id), do: Repo.get!(Radusergroup, id)

  def create_radusergroup(attrs \\ %{}) do
    %Radusergroup{}
    |> Radusergroup.changeset(attrs)
    |> Repo.insert()
  end

  def update_radusergroup(%Radusergroup{} = radusergroup, attrs) do
    radusergroup
    |> Radusergroup.changeset(attrs)
    |> Repo.update()
  end

  def delete_radusergroup(%Radusergroup{} = radusergroup) do
    Repo.delete(radusergroup)
  end
end
