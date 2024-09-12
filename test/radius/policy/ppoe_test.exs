defmodule Radius.Policy.PpoeTest do
  use Radius.DataCase
  alias Radius.Policy.Ppoe
  alias Radius.Group.{Radgroupcheck, Radgroupreply}
  alias Radius.UserGroup.Radusergroup
  alias Radius.Repo

  setup do
    # Create a sample policy struct for testing
    policy = %Ppoe{
      pool: "test_pool",
      plan: Ecto.UUID.generate(),
      profile: "test_profile",
      upload: 10,
      download: 5,
      duration: 3600,
      priority: 1
    }
    {:ok, policy: policy}
  end

  describe "add_policies/1" do
    test "successfully adds policies", %{policy: policy} do
      assert {:ok, :ok} = Ppoe.add_policies(policy)

      # Verify Radgroupcheck
      assert Repo.get_by(Radgroupcheck, groupname: policy.profile, plan: policy.plan)

      # Verify Radusergroup
      assert Repo.get_by(Radusergroup, username: policy.profile, groupname: policy.plan)

      # Verify Radgroupreply
      assert Repo.get_by(Radgroupreply, groupname: policy.plan, attribute: "Mikrotik-Rate-Limit")
      assert Repo.get_by(Radgroupreply, groupname: policy.plan, attribute: "Session-Timeout")
      assert Repo.get_by(Radgroupreply, groupname: policy.plan, attribute: "Framed-Pool")
    end
  end

  describe "update_policies/1" do
    test "successfully updates policies", %{policy: policy} do
      # First, add the policies
      {:ok, :ok} = Ppoe.add_policies(policy)

      # Update the policy
      updated_policy = %{policy | upload: 20, download: 10, duration: 7200}
      assert {:ok, :ok} = Ppoe.update_policies(updated_policy)

      # Verify updates
      assert Repo.get_by(Radgroupreply, groupname: policy.plan, attribute: "Mikrotik-Rate-Limit", value: "20/M10/M")
      assert Repo.get_by(Radgroupreply, groupname: policy.plan, attribute: "Session-Timeout", value: "7200")
    end
  end

  describe "delete_policies/1" do
    test "successfully deletes policies", %{policy: policy} do
      # First, add the policies
      {:ok, :ok} = Ppoe.add_policies(policy)

      # Delete the policies
      assert {:ok, :ok} = Ppoe.delete_policies(policy.plan)

      # Verify deletions
      refute Repo.get_by(Radgroupcheck, plan: policy.plan)
      refute Repo.get_by(Radusergroup, groupname: policy.plan)
      refute Repo.get_by(Radgroupreply, groupname: policy.plan)
    end
  end
end
