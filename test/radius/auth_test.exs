defmodule Radius.AuthTest do
  use Radius.DataCase

  alias Radius.Auth
  alias Radius.Auth.{Radcheck, Hotspot, Ppoe}

  describe "login/2" do
    test "login/2 with :hotspot creates a new hotspot session" do
      attrs = %{
        username: "test_user",
        password: "password123",
        customer: Ecto.UUID.generate(),
        duration_mins: 5,
        plan: Ecto.UUID.generate(),
        priority: 1
      }

      assert {:ok, %Hotspot{}} = Auth.login(:hotspot, attrs)
      assert Repo.get_by(Radcheck, username: "test_user") != nil
      assert Repo.get_by(Radcheck, username: "test_user").customer == attrs.customer
    end

    test "login/2 with :hotspot returns error when session already exists" do
      attrs = %{
        username: "existing_user",
        password: "password123",
        customer: Ecto.UUID.generate(),
        duration_mins: 5,
        plan: Ecto.UUID.generate(),
        priority: 1
      }

      # Create the initial session
      assert {:ok, %Hotspot{}} = Auth.login(:hotspot, attrs)

      # Attempt to create a session with the same username
      assert {:error, :session_exists} = Auth.login(:hotspot, attrs)

      # Verify that only one session exists
      assert Repo.aggregate(Radcheck, :count, :id) == 1
    end

    test "login/2 with :hotspot throws error for invalid attributes" do
      invalid_attrs = %{
        username: nil,
        password: nil,
        customer: nil,
        duration_mins: nil,
        plan: nil,
        priority: 1
      }

      assert {:error, %Ecto.Changeset{valid?: false}} = Auth.login(:hotspot, invalid_attrs)
    end

    test "login/2 with :ppoe creates a new ppoe session" do
      attrs = %{
        username: "test_user",
        password: "password123",
        customer: Ecto.UUID.generate(),
        duration_mins: 5,
        profile: "default"
      }

      assert {:ok, %Ppoe{}} = Auth.login(:ppoe, attrs)
    end

    test "login/2 with :ppoe returns error when session already exists" do
      attrs = %{
        username: "existing_user",
        password: "password123",
        customer: Ecto.UUID.generate(),
        duration_mins: 5,
        plan: Ecto.UUID.generate(),
        priority: 1,
        profile: "default"
      }

      # Create the initial session
      assert {:ok, %Ppoe{}} = Auth.login(:ppoe, attrs)

      # Attempt to create a session with the same username
      assert {:error, :session_exists} = Auth.login(:ppoe, attrs)

      # Verify that only one session exists
      assert Repo.aggregate(Radcheck, :count, :id) == 2
    end

    test "login/2 with :ppoe throws error for invalid attributes" do
      invalid_attrs = %{
        username: nil,
        password: nil,
        customer: nil,
        duration_mins: nil,
        plan: nil,
        priority: 1
      }

      assert {:error, %Ecto.Changeset{valid?: false}} = Auth.login(:ppoe, invalid_attrs)
    end
  end

  describe "logout/2" do
    test "logout/2 with :hotspot removes the hotspot session" do
      attrs = %{
        username: "test_user",
        password: "password123",
        customer: Ecto.UUID.generate(),
        duration_mins: 5,
        plan: Ecto.UUID.generate(),
        priority: 1
      }

      {:ok, %Hotspot{}} = Auth.login(:hotspot, attrs)

      assert {:ok, :ok} = Auth.logout(:hotspot, attrs.customer)
      assert Repo.get_by(Radcheck, username: "test_user") == nil
    end

    test "logout/2 with :ppoe removes the ppoe session" do
      attrs = %{
        username: "test_user",
        password: "password123",
        customer: Ecto.UUID.generate(),
        duration_mins: 5,
        profile: "default"
      }

      {:ok, %Ppoe{}} = Auth.login(:ppoe, attrs)

      assert {:ok, :ok} = Auth.logout(:ppoe, attrs.customer)
      assert Repo.get_by(Radcheck, username: "test_user") == nil
    end
  end

  describe "extend_session/1" do
    test "extend_session/1 successfully extends an existing session" do
      # Create an initial session
      initial_attrs = %{
        username: "test_user",
        password: "password123",
        customer: Ecto.UUID.generate(),
        duration_mins: 5,
        plan: Ecto.UUID.generate(),
        priority: 1
      }

      {:ok, %Hotspot{}} = Auth.login(:hotspot, initial_attrs)

      # Extend the session

      extend_attrs = %{
        customer: initial_attrs.customer,
        duration_mins: 10
      }

      assert {:ok, :ok} = Auth.extend_session(extend_attrs)
    end

    test "extend_session/1 returns error for non-existent session" do
      non_existent_attrs = %{
        customer: Ecto.UUID.generate(),
        duration_mins: 5
      }

      assert {:error, :customer_session_not_found} = Auth.extend_session(non_existent_attrs)
    end

    test "extend_session/1 returns error for invalid attributes" do
      invalid_attrs = %{
        customer: nil,
        duration_mins: nil
      }

      assert {:error, %Ecto.Changeset{valid?: false}} = Auth.extend_session(invalid_attrs)
    end
  end
end
