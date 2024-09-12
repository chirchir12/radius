defmodule Radius.Auth.RadcheckTest do
  use Radius.DataCase, async: true
  alias Radius.Auth.Radcheck

  describe "Radcheck" do
    @valid_attrs %{
      username: "testuser",
      attribute: "Password",
      op: ":=",
      value: "secret",
      service: "hotspot",
      customer: Ecto.UUID.generate(),
      expire_on: DateTime.utc_now() |> DateTime.add(7, :day)
    }

    test "create_radcheck/1 with valid data creates a radcheck entry" do
      assert {:ok, %Radcheck{} = radcheck} = Radcheck.create_radcheck(@valid_attrs)
      assert radcheck.username == "testuser"
      assert radcheck.attribute == "Password"
      assert radcheck.op == ":="
      assert radcheck.value == "secret"
      assert radcheck.customer == @valid_attrs.customer
    end

    test "create_radcheck/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Radcheck.create_radcheck(%{})
    end

    test "get_by/1 returns the radcheck entry with given customer" do
      {:ok, radcheck} = Radcheck.create_radcheck(@valid_attrs)
      assert {:ok, found_radcheck} = Radcheck.get_by(radcheck.customer)
      assert found_radcheck.id == radcheck.id
    end

    test "get_by/1 returns error when customer not found" do
      assert {:error, :customer_session_not_found} = Radcheck.get_by(Ecto.UUID.generate())
    end

    test "delete_radcheck/1 deletes the radcheck entry" do
      {:ok, radcheck} = Radcheck.create_radcheck(@valid_attrs)
      assert {:ok, %Radcheck{}} = Radcheck.delete_radcheck(radcheck)
      assert {:error, :customer_session_not_found} = Radcheck.get_by(radcheck.customer)
    end

    test "changeset/2 validates service field" do
      changeset = Radcheck.changeset(%Radcheck{}, Map.put(@valid_attrs, :service, "invalid"))
      assert %{service: ["must be either 'ppp' or 'hotspot'"]} = errors_on(changeset)

      changeset = Radcheck.changeset(%Radcheck{}, Map.put(@valid_attrs, :service, "ppp"))
      assert changeset.valid?
      assert get_change(changeset, :customer) == @valid_attrs.customer

      changeset = Radcheck.changeset(%Radcheck{}, Map.put(@valid_attrs, :service, "hotspot"))
      assert changeset.valid?
      assert get_change(changeset, :customer) == @valid_attrs.customer
    end
  end
end
