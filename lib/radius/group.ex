defmodule Radius.Group do
  import Ecto.Query, warn: false
  alias Radius.Repo
  alias Radius.Group.{Radgroupcheck, Radgroupreply}

  # Radgroupcheck functions
  def list_radgroupchecks do
    Repo.all(Radgroupcheck)
  end

  def get_radgroupcheck!(id), do: Repo.get!(Radgroupcheck, id)

  def create_radgroupcheck(attrs \\ %{}) do
    %Radgroupcheck{}
    |> Radgroupcheck.changeset(attrs)
    |> Repo.insert()
  end

  def delete_radgroupcheck(%Radgroupcheck{} = radgroupcheck) do
    Repo.delete(radgroupcheck)
  end

  # Radgroupreply functions
  def list_radgroupreplies do
    Repo.all(Radgroupreply)
  end

  def get_radgroupreply!(id), do: Repo.get!(Radgroupreply, id)

  def create_radgroupreply(attrs \\ %{}) do
    %Radgroupreply{}
    |> Radgroupreply.changeset(attrs)
    |> Repo.insert()
  end

  def delete_radgroupreply(%Radgroupreply{} = radgroupreply) do
    Repo.delete(radgroupreply)
  end
end
