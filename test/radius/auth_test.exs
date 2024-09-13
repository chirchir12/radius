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
end
