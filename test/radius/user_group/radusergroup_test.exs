defmodule Radius.UserGroup.RadusergroupTest do
  use Radius.DataCase, async: true
  alias Radius.UserGroup.Radusergroup

  describe "radusergroup" do
    @valid_attrs %{
      username: "testuser",
      groupname: "testgroup",
      priority: 1,
      service: "hotspot",
      customer: Ecto.UUID.generate()
    }
    @valid_ppp_attrs %{username: "pppuser", groupname: "pppgroup", priority: 1, service: "ppp"}

    test "create_radusergroup/1 with valid hotspot data creates a radusergroup" do
      assert {:ok, %Radusergroup{} = radusergroup} =
               Radusergroup.create_radusergroup(@valid_attrs)

      assert radusergroup.username == "testuser"
      assert radusergroup.groupname == "testgroup"
      assert radusergroup.priority == 1
      assert radusergroup.service == "hotspot"
      assert radusergroup.customer == @valid_attrs.customer
    end

    test "create_radusergroup/1 with valid ppp data creates a radusergroup" do
      assert {:ok, %Radusergroup{} = radusergroup} =
               Radusergroup.create_radusergroup(@valid_ppp_attrs)

      assert radusergroup.username == "pppuser"
      assert radusergroup.groupname == "pppgroup"
      assert radusergroup.priority == 1
      assert radusergroup.service == "ppp"
      assert is_nil(radusergroup.customer)
    end

    test "create_radusergroup/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Radusergroup.create_radusergroup(%{})
    end

    test "create_radusergroup/1 with hotspot service and missing customer returns error changeset" do
      attrs = Map.put(@valid_attrs, :customer, nil)
      assert {:error, %Ecto.Changeset{} = changeset} = Radusergroup.create_radusergroup(attrs)
      assert "can't be blank" in errors_on(changeset).customer
    end

    test "create_radusergroup/1 with ppp service and customer returns valid radusergroup with nil customer" do
      attrs = Map.put(@valid_ppp_attrs, :customer, Ecto.UUID.generate())
      assert {:ok, %Radusergroup{} = radusergroup} = Radusergroup.create_radusergroup(attrs)
      assert not is_nil(radusergroup.customer)
    end

    test "create_radusergroup/1 with invalid service returns error changeset" do
      attrs = Map.put(@valid_attrs, :service, "invalid")
      assert {:error, %Ecto.Changeset{} = changeset} = Radusergroup.create_radusergroup(attrs)
      assert "must be either 'ppp' or 'hotspot'" in errors_on(changeset).service
    end

    test "get_by/1 returns the radusergroup with given customer" do
      {:ok, radusergroup} = Radusergroup.create_radusergroup(@valid_attrs)
      assert {:ok, %Radusergroup{}} = Radusergroup.get_by(radusergroup.customer)
    end

    test "get_by/1 returns error when customer not found" do
      assert {:error, :customer_session_not_found} = Radusergroup.get_by(Ecto.UUID.generate())
    end

    test "update_radusergroup/2 with valid data updates the radusergroup" do
      {:ok, radusergroup} = Radusergroup.create_radusergroup(@valid_attrs)
      update_attrs = %{groupname: "updated_group"}

      assert {:ok, %Radusergroup{} = updated} =
               Radusergroup.update_radusergroup(radusergroup, update_attrs)

      assert updated.groupname == "updated_group"
    end

    test "update_radusergroup/2 with invalid data returns error changeset" do
      {:ok, radusergroup} = Radusergroup.create_radusergroup(@valid_attrs)

      assert {:error, %Ecto.Changeset{}} =
               Radusergroup.update_radusergroup(radusergroup, %{username: nil})
    end

    test "delete_radusergroup/1 deletes the radusergroup" do
      {:ok, radusergroup} = Radusergroup.create_radusergroup(@valid_attrs)
      assert {:ok, %Radusergroup{}} = Radusergroup.delete_radusergroup(radusergroup)
      assert {:error, :customer_session_not_found} = Radusergroup.get_by(radusergroup.customer)
    end
  end
end
