defmodule Radius.PoliciesTest do
  use Radius.DataCase

  alias Radius.Policies

  describe "hotspot policies" do
    @valid_attrs %{plan: Ecto.UUID.generate(), upload: 1024, download: 2048, duration: 3600}
    @invalid_attrs %{plan: Ecto.UUID.generate(), upload: nil, download: nil, duration: nil}

    test "add/2 creates a hotspot policy" do
      assert {:ok, :ok} = Policies.add(:hotspot, @valid_attrs)
    end

    test "add/2 returns an error if the policy already exists" do
      {:ok, :ok} = Policies.add(:hotspot, @valid_attrs)
      assert {:error, :policy_exists} = Policies.add(:hotspot, @valid_attrs)
    end

    test "add/2 return invalid changeset if attrs is not valid" do
      assert {:error, %Ecto.Changeset{valid?: false}} = Policies.add(:hotspot, @invalid_attrs)
    end

    test "update/2 updates a hotspot policy" do
      {:ok, :ok} = Policies.add(:hotspot, @valid_attrs)
      update_attrs = %{@valid_attrs | upload: 2048, download: 4096}

      assert {:ok, :ok} = Policies.update(:hotspot, update_attrs)
    end

    test "delete/2 deletes a hotspot policy" do
      {:ok, :ok} = Policies.add(:hotspot, @valid_attrs)
      assert {:ok, :ok} = Policies.delete(:hotspot, @valid_attrs.plan)
    end
  end

  describe "ppoe policies" do
    @valid_attrs %{
      plan: Ecto.UUID.generate(),
      upload: 5120,
      download: 10240,
      duration: 7200,
      priority: 1,
      pool: "main",
      profile: "default"
    }

    test "add/2 creates a ppoe policy" do
      assert {:ok, :ok} = Policies.add(:ppoe, @valid_attrs)
    end

    test "update/2 updates a ppoe policy" do
      {:ok, :ok} = Policies.add(:ppoe, @valid_attrs)
      update_attrs = %{@valid_attrs | upload: 10240, download: 20480, priority: 2}

      assert {:ok, :ok} = Policies.update(:ppoe, update_attrs)
    end

    test "delete/2 deletes a ppoe policy" do
      {:ok, :ok} = Policies.add(:ppoe, @valid_attrs)
      assert {:ok, :ok} = Policies.delete(:ppoe, @valid_attrs.plan)
    end
  end
end
