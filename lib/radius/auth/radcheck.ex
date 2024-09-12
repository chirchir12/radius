defmodule Radius.Auth.Radcheck do
  alias Radius.Repo
  use Ecto.Schema
  import Ecto.Changeset

  schema "radcheck" do
    field :username, :string
    field :attribute, :string
    field :op, :string
    field :value, :string
    field :customer, Ecto.UUID
    field :service, :string, virtual: true
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

      "ppp" ->
        put_change(changeset, :customer, nil)

      nil ->
        add_error(changeset, :service, "must be either 'ppp' or 'hotspot'")

      _ ->
        add_error(changeset, :service, "must be either 'ppp' or 'hotspot'")
    end
  end
end
