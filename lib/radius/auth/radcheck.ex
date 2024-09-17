defmodule Radius.Auth.Radcheck do
  alias Radius.Repo
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  schema "radcheck" do
    field :username, :string
    field :attribute, :string
    field :op, :string
    field :value, :string
    field :customer, Ecto.UUID
    field :service, :string
    field :expire_on, :utc_datetime
  end

  def create_radcheck(attrs \\ %{}) do
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

  def delete_radcheck(%__MODULE__{} = radcheck) do
    Repo.delete(radcheck)
  end

  def fetch_and_delete_expired_check(customer, service) when service in ["hotspot", "ppoe"] do
    now = DateTime.utc_now()

    query =
      from(r in __MODULE__,
        where: r.expire_on <= ^now and r.customer == ^customer and r.service == ^service,
        select: r
      )

    case Repo.delete_all(query) do
      {0, []} -> {:error, :no_session_to_delete}
      {_count, deleted_items} -> {:ok, deleted_items}
    end
  end

  def fetch_and_delete_expired_check(customer) do
    now = DateTime.utc_now()

    query =
      from(r in __MODULE__, where: r.expire_on <= ^now and r.customer == ^customer, select: r)

    case Repo.delete_all(query) do
      {0, []} -> {:error, :no_session_to_delete}
      {_count, deleted_items} -> {:ok, deleted_items}
    end
  end

  def fetch_and_delete_expired_check() do
    now = DateTime.utc_now()
    query = from(r in __MODULE__, where: r.expire_on <= ^now, select: r)

    case Repo.delete_all(query) do
      {0, []} -> {:error, :no_session_to_delete}
      {_count, deleted_items} -> {:ok, deleted_items}
    end
  end

  def changeset(radcheck, attrs) do
    radcheck
    |> cast(attrs, [:username, :attribute, :op, :value, :customer, :service, :expire_on])
    |> validate_required([:username, :attribute, :op, :value, :service, :expire_on])
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
