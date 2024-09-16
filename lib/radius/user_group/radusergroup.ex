defmodule Radius.UserGroup.Radusergroup do
  alias Radius.Repo
  use Ecto.Schema
  import Ecto.Changeset

  schema "radusergroup" do
    field :username, :string
    field :groupname, :string
    field :priority, :integer, default: 0
    field :customer, Ecto.UUID
    field :service, :string, virtual: true
  end

  def create_radusergroup(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def get_by(customer) do
    case Repo.get_by(__MODULE__, customer: customer) do
      nil ->
        {:error, :customer_session_not_found}

      user_group ->
        {:ok, user_group}
    end
  end

  def delete_radusergroup(%__MODULE__{} = radusergroup) do
    Repo.delete(radusergroup)
  end

  def update_radusergroup(%__MODULE__{} = radusergroup, attrs) do
    radusergroup
    |> changeset(attrs)
    |> Repo.update()
  end

  def changeset(radusergroup, attrs) do
    radusergroup
    |> cast(attrs, [:username, :groupname, :priority, :customer, :service])
    |> validate_required([:username, :groupname, :service])
    |> validate_service()
  end

  defp validate_service(changeset) do
    case get_field(changeset, :service) do
      "hotspot" ->
        validate_required(changeset, [:customer])

      "ppoe" ->
        changeset

      nil ->
        add_error(changeset, :service, "must be either 'ppoe' or 'hotspot'")

      _ ->
        add_error(changeset, :service, "must be either 'ppoe' or 'hotspot'")
    end
  end
end
