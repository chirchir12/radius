defmodule Radius.AuthTest do
  use Radius.DataCase

  alias Radius.Auth
  alias Radius.Auth.{Radcheck}

  describe "login/2" do
    test "login/2 with :hotspot creates a new hotspot session" do
      attrs = %{
        username: "test_user",
        password: "password123",
        customer: Ecto.UUID.generate(),
        expire_on: DateTime.utc_now() |> DateTime.add(3600, :second),
        plan: Ecto.UUID.generate(),
        priority: 1
      }

      assert {:ok, :ok} = Auth.login(:hotspot, attrs)
      assert Repo.get_by(Radcheck, username: "test_user") != nil
      assert Repo.get_by(Radcheck, username: "test_user").customer == attrs.customer
    end

    test "login/2 with :hotspot returns error when session already exists" do
      attrs = %{
        username: "existing_user",
        password: "password123",
        customer: Ecto.UUID.generate(),
        expire_on: DateTime.utc_now() |> DateTime.add(3600, :second),
        plan: Ecto.UUID.generate(),
        priority: 1
      }

      # Create the initial session
      assert {:ok, :ok} = Auth.login(:hotspot, attrs)

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
        expire_on: nil,
        plan: nil,
        priority: 1
      }

      assert {:error, %Ecto.Changeset{valid?: false}} = Auth.login(:hotspot, invalid_attrs)
    end

    test "login/2 with :ppp creates a new ppp session" do
      attrs = %{
        username: "test_user",
        password: "password123",
        customer: Ecto.UUID.generate(),
        expire_on: DateTime.utc_now() |> DateTime.add(3600, :second),
        profile: "default"
      }

      assert {:ok, :ok} = Auth.login(:ppp, attrs)
    end

    test "login/2 with :ppp returns error when session already exists" do
      attrs = %{
        username: "existing_user",
        password: "password123",
        customer: Ecto.UUID.generate(),
        expire_on: DateTime.utc_now() |> DateTime.add(3600, :second),
        plan: Ecto.UUID.generate(),
        priority: 1,
        profile: "default"
      }

      # Create the initial session
      assert {:ok, :ok} = Auth.login(:ppp, attrs)

      # Attempt to create a session with the same username
      assert {:error, :session_exists} = Auth.login(:ppp, attrs)

      # Verify that only one session exists
      assert Repo.aggregate(Radcheck, :count, :id) == 2
    end

    test "login/2 with :ppp throws error for invalid attributes" do
      invalid_attrs = %{
        username: nil,
        password: nil,
        customer: nil,
        expire_on: nil,
        plan: nil,
        priority: 1
      }

      assert {:error, %Ecto.Changeset{valid?: false}} = Auth.login(:ppp, invalid_attrs)
    end
  end

  describe "logout/2" do
    test "logout/2 with :hotspot removes the hotspot session" do
      attrs = %{
        username: "test_user",
        password: "password123",
        customer: Ecto.UUID.generate(),
        expire_on: DateTime.utc_now() |> DateTime.add(3600, :second),
        plan: Ecto.UUID.generate(),
        priority: 1
      }

      {:ok, :ok} = Auth.login(:hotspot, attrs)

      assert {:ok, :ok} = Auth.logout(:hotspot, attrs.customer)
      assert Repo.get_by(Radcheck, username: "test_user") == nil
    end

    test "logout/2 with :ppp removes the ppp session" do
      attrs = %{
        username: "test_user",
        password: "password123",
        customer: Ecto.UUID.generate(),
        expire_on: DateTime.utc_now() |> DateTime.add(3600, :second),
        profile: "default"
      }

      {:ok, :ok} = Auth.login(:ppp, attrs)

      assert {:ok, :ok} = Auth.logout(:ppp, attrs.customer)
      assert Repo.get_by(Radcheck, username: "test_user") == nil
    end
  end

  describe "clear_session/0" do
    test "clear_session/0 removes expired sessions" do
      expired_attrs = %{
        username: "expired_user",
        password: "password123",
        customer: Ecto.UUID.generate(),
        expire_on: DateTime.utc_now() |> DateTime.add(-3600, :second),
        plan: Ecto.UUID.generate(),
        priority: 1
      }

      {:ok, :ok} = Auth.login(:hotspot, expired_attrs)

      valid_attrs = %{
        username: "valid_user",
        password: "password123",
        customer: Ecto.UUID.generate(),
        expire_on: DateTime.utc_now() |> DateTime.add(3600, :second),
        plan: Ecto.UUID.generate(),
        priority: 1
      }

      {:ok, :ok} = Auth.login(:hotspot, valid_attrs)

      Auth.clear_session()

      assert Repo.get_by(Radcheck, username: "expired_user") == nil
      assert Repo.get_by(Radcheck, username: "valid_user") != nil
    end
  end

  describe "extend_session/1" do
    test "extend_session/1 successfully extends an existing session" do
      # Create an initial session
      initial_attrs = %{
        username: "test_user",
        password: "password123",
        customer: Ecto.UUID.generate(),
        expire_on: DateTime.utc_now() |> DateTime.add(3600, :second),
        plan: Ecto.UUID.generate(),
        priority: 1
      }

      {:ok, :ok} = Auth.login(:hotspot, initial_attrs)

      # Extend the session
      new_expiration = DateTime.utc_now() |> DateTime.add(7200, :second)

      extend_attrs = %{
        customer: initial_attrs.customer,
        expire_on: new_expiration
      }

      assert {:ok, :ok} = Auth.extend_session(extend_attrs)
    end

    test "extend_session/1 returns error for non-existent session" do
      non_existent_attrs = %{
        customer: Ecto.UUID.generate(),
        expire_on: DateTime.utc_now() |> DateTime.add(3600, :second)
      }

      assert {:error, :customer_session_not_found} = Auth.extend_session(non_existent_attrs)
    end

    test "extend_session/1 returns error for invalid attributes" do
      invalid_attrs = %{
        customer: nil,
        expire_on: "invalid_date"
      }

      assert {:error, %Ecto.Changeset{valid?: false}} = Auth.extend_session(invalid_attrs)
    end
  end
end
