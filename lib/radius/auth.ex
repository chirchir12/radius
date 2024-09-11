defmodule Radius.Auth do
  import Ecto.Query, warn: false
  alias Radius.Repo
  alias Radius.Auth.{Radcheck, Radreply}

  # Radcheck functions
  def list_radchecks do
    Repo.all(Radcheck)
  end

  def get_radcheck!(id), do: Repo.get!(Radcheck, id)

  def create_radcheck(attrs \\ %{}) do
    %Radcheck{}
    |> Radcheck.changeset(attrs)
    |> Repo.insert()
  end

  def update_radcheck(%Radcheck{} = radcheck, attrs) do
    radcheck
    |> Radcheck.changeset(attrs)
    |> Repo.update()
  end

  def delete_radcheck(%Radcheck{} = radcheck) do
    Repo.delete(radcheck)
  end

  # Radreply functions
  def list_radreplies do
    Repo.all(Radreply)
  end

  def get_radreply!(id), do: Repo.get!(Radreply, id)

  def create_radreply(attrs \\ %{}) do
    %Radreply{}
    |> Radreply.changeset(attrs)
    |> Repo.insert()
  end

  def update_radreply(%Radreply{} = radreply, attrs) do
    radreply
    |> Radreply.changeset(attrs)
    |> Repo.update()
  end

  def delete_radreply(%Radreply{} = radreply) do
    Repo.delete(radreply)
  end
end
