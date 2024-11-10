defmodule Radius.Auth.PpoeTest do
  use Radius.DataCase, async: true

  alias Radius.Auth.Ppoe
  alias Radius.Auth.Radcheck
  alias Radius.Repo

  describe "Ppoe.login/1" do
    test "successfully creates radcheck entries for valid credentials and profile" do
      attrs = %Ppoe{
        username: "testuser",
        password: "testpass",
        subscription_uuid: Ecto.UUID.generate(),
        service: "ppp",
        expire_on: ~N[2023-12-31 23:59:59]
      }

      assert {:ok, %Ppoe{}} = Ppoe.login(attrs)

      # Verify credentials entry
      assert %Radcheck{} =
               cred = Repo.get_by(Radcheck, username: "testuser", attribute: "Cleartext-Password")

      assert cred.value == "testpass"
      assert cred.customer == attrs.subscription_uuid
      assert cred.expire_on != nil

      # Verify profile entry
      assert %Radcheck{} =
               prof = Repo.get_by(Radcheck, username: "testuser", attribute: "User-Profile")

      assert prof.value == "testprofile"
      assert prof.customer == attrs.subscription_uuid
      assert prof.expire_on != nil
    end

    test "returns error for invalid attributes" do
      invalid_attrs = %Ppoe{
        username: nil,
        password: nil,
        subscription_uuid: nil,
        service: "ppp",
        expire_on: nil
      }

      assert {:error, %{credentials: _, profile: _}} = Ppoe.login(invalid_attrs)
    end
  end

  describe "Ppoe.logout/1" do
    test "successfully removes all radcheck entries for a customer" do
      # Setup: Create some test entries
      subscription_uuid = Ecto.UUID.generate()

      Repo.insert_all(Radcheck, [
        %{
          username: "user1",
          attribute: "Cleartext-Password",
          op: ":=",
          value: "pass1",
          customer: subscription_uuid,
          expire_on: ~U[2023-12-31 23:59:59Z],
          service: "ppp"
        },
        %{
          username: "user1",
          attribute: "User-Profile",
          op: ":=",
          value: "profile1",
          customer: subscription_uuid,
          expire_on: ~U[2023-12-31 23:59:59Z],
          service: "ppp"
        },
        %{
          username: "user2",
          attribute: "Cleartext-Password",
          op: ":=",
          value: "pass2",
          customer: subscription_uuid,
          expire_on: ~U[2023-12-31 23:59:59Z],
          service: "ppp"
        },
        %{
          username: "user2",
          attribute: "User-Profile",
          op: ":=",
          value: "profile2",
          customer: subscription_uuid,
          expire_on: ~U[2023-12-31 23:59:59Z],
          service: "ppp"
        }
      ])

      assert Repo.aggregate(Radcheck, :count, :id) == 4

      # Perform logout
      assert {:ok, :ok} = Ppoe.logout(subscription_uuid)

      # Verify all entries for the customer are removed
      assert Repo.aggregate(Radcheck, :count, :id) == 0
    end

    test "does not remove entries for other customers" do
      # Setup: Create entries for multiple customers
      sub_uuid_1 = Ecto.UUID.generate()
      sub_uuid_2 = Ecto.UUID.generate()

      Repo.insert_all(Radcheck, [
        %{
          username: "user1",
          attribute: "Cleartext-Password",
          op: ":=",
          value: "pass1",
          customer: sub_uuid_1,
          expire_on: ~U[2023-12-31 23:59:59Z],
          service: "ppp"
        },
        %{
          username: "user2",
          attribute: "Cleartext-Password",
          op: ":=",
          value: "pass2",
          customer: sub_uuid_2,
          expire_on: ~U[2023-12-31 23:59:59Z],
          service: "ppp"
        }
      ])

      assert Repo.aggregate(Radcheck, :count, :id) == 2

      # Perform logout for customer1
      assert {:ok, :ok} = Ppoe.logout(sub_uuid_1)

      # Verify only customer1's entry is removed
      assert Repo.aggregate(Radcheck, :count, :id) == 1
      assert Repo.get_by(Radcheck, customer: sub_uuid_2) != nil
    end
  end
end
