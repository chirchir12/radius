defmodule Radius.Policy.HotspotTest do
  use Radius.DataCase
  alias Radius.Policy.Hotspot
  alias Radius.Group.{Radgroupcheck, Radgroupreply}
  import Ecto.Query

  describe "add_policies/1" do
    test "successfully adds a new policy" do
      attrs = %Hotspot{
        plan: Ecto.UUID.generate(),
        upload: 10,
        download: 5,
        duration: "3600"
      }

      assert {:ok, :ok} = Hotspot.add_policies(attrs)

      # Verify Radgroupcheck entries
      assert [check1, check2] =
               Repo.all(from c in Radgroupcheck, where: c.groupname == ^attrs.plan)

      assert check1.attribute == "Mikrotik-Rate-Limit"
      assert check1.value == "10/M5/M"
      assert check2.attribute == "Session-Timeout"
      assert check2.value == "3600"

      # Verify Radgroupreply entries
      assert [reply1, reply2] =
               Repo.all(from r in Radgroupreply, where: r.groupname == ^attrs.plan)

      assert reply1.attribute == "Mikrotik-Rate-Limit"
      assert reply1.value == "10/M5/M"
      assert reply2.attribute == "Session-Timeout"
      assert reply2.value == "3600"
    end

    test "returns error when invalid attributes are provided" do
      attrs = %Hotspot{
        plan: nil,
        upload: -1,
        download: -1,
        duration: "invalid"
      }

      assert {:error, _errors} = Hotspot.add_policies(attrs)
    end
  end

  describe "update_policies/1" do
    setup do
      attrs = %Hotspot{
        plan: Ecto.UUID.generate(),
        upload: 10,
        download: 5,
        duration: "3600"
      }

      {:ok, :ok} = Hotspot.add_policies(attrs)
      %{initial_attrs: attrs}
    end

    test "successfully updates an existing policy", %{initial_attrs: initial_attrs} do
      updated_attrs = %Hotspot{
        plan: initial_attrs.plan,
        upload: 20,
        download: 10,
        duration: "7200"
      }

      assert {:ok, :ok} = Hotspot.update_policies(updated_attrs)

      # Verify updated Radgroupcheck entries
      assert [check1, check2] =
               Repo.all(from c in Radgroupcheck, where: c.groupname == ^updated_attrs.plan)

      assert check1.attribute == "Mikrotik-Rate-Limit"
      assert check1.value == "20/M10/M"
      assert check2.attribute == "Session-Timeout"
      assert check2.value == "7200"

      # Verify updated Radgroupreply entries
      assert [reply1, reply2] =
               Repo.all(from r in Radgroupreply, where: r.groupname == ^updated_attrs.plan)

      assert reply1.attribute == "Mikrotik-Rate-Limit"
      assert reply1.value == "20/M10/M"
      assert reply2.attribute == "Session-Timeout"
      assert reply2.value == "7200"
    end

    test "returns ok when trying to update non-existent policy" do
      non_existent_attrs = %Hotspot{
        plan: Ecto.UUID.generate(),
        upload: 20,
        download: 10,
        duration: "7200"
      }

      assert {:ok, :ok} = Hotspot.update_policies(non_existent_attrs)

      # Note: This test assumes the current behavior. You might want to change this if you expect a different outcome for non-existent policies.
    end
  end

  describe "delete_policies/1" do
    setup do
      attrs = %Hotspot{
        plan: Ecto.UUID.generate(),
        upload: 10,
        download: 5,
        duration: "3600"
      }

      {:ok, :ok} = Hotspot.add_policies(attrs)
      %{plan: attrs.plan}
    end

    test "successfully deletes an existing policy", %{plan: plan} do
      assert {:ok, :ok} = Hotspot.delete_policies(plan)

      # Verify Radgroupcheck entries are deleted
      assert [] = Repo.all(from c in Radgroupcheck, where: c.groupname == ^plan)

      # Verify Radgroupreply entries are deleted
      assert [] = Repo.all(from r in Radgroupreply, where: r.groupname == ^plan)
    end

    test "returns ok when trying to delete non-existent policy" do
      non_existent_plan = Ecto.UUID.generate()
      assert {:ok, :ok} = Hotspot.delete_policies(non_existent_plan)
    end
  end
end
