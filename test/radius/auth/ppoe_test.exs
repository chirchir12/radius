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
        customer: Ecto.UUID.generate(),
        service: "ppp",
        expire_on: ~N[2023-12-31 23:59:59],
        profile: "testprofile"
      }

      assert {:ok, :ok} = Ppoe.login(attrs)

      # Verify credentials entry
      assert %Radcheck{} =
               cred = Repo.get_by(Radcheck, username: "testuser", attribute: "Cleartext-Password")

      assert cred.value == "testpass"
      assert cred.customer == attrs.customer
      assert cred.expire_on != nil

      # Verify profile entry
      assert %Radcheck{} =
               prof = Repo.get_by(Radcheck, username: "testuser", attribute: "User-Profile")

      assert prof.value == "testprofile"
      assert prof.customer == attrs.customer
      assert prof.expire_on != nil
    end

    test "returns error for invalid attributes" do
      invalid_attrs = %Ppoe{
        username: nil,
        password: nil,
        customer: nil,
        service: "ppp",
        expire_on: nil,
        profile: nil
      }

      assert {:error, %{credentials: _, profile: _}} = Ppoe.login(invalid_attrs)
    end
  end

  describe "Ppoe.logout/1" do
    test "successfully removes all radcheck entries for a customer" do
      # Setup: Create some test entries
      customer = Ecto.UUID.generate()

      Repo.insert_all(Radcheck, [
        %{
          username: "user1",
          attribute: "Cleartext-Password",
          op: ":=",
          value: "pass1",
          customer: customer,
          expire_on: ~U[2023-12-31 23:59:59Z],
          service: "ppp"
        },
        %{
          username: "user1",
          attribute: "User-Profile",
          op: ":=",
          value: "profile1",
          customer: customer,
          expire_on: ~U[2023-12-31 23:59:59Z],
          service: "ppp"
        },
        %{
          username: "user2",
          attribute: "Cleartext-Password",
          op: ":=",
          value: "pass2",
          customer: customer,
          expire_on: ~U[2023-12-31 23:59:59Z],
          service: "ppp"
        },
        %{
          username: "user2",
          attribute: "User-Profile",
          op: ":=",
          value: "profile2",
          customer: customer,
          expire_on: ~U[2023-12-31 23:59:59Z],
          service: "ppp"
        }
      ])

      assert Repo.aggregate(Radcheck, :count, :id) == 4

      # Perform logout
      assert {:ok, :ok} = Ppoe.logout(customer)

      # Verify all entries for the customer are removed
      assert Repo.aggregate(Radcheck, :count, :id) == 0
    end

    test "does not remove entries for other customers" do
      # Setup: Create entries for multiple customers
      user1_customer = Ecto.UUID.generate()
      user2_customer = Ecto.UUID.generate()

      Repo.insert_all(Radcheck, [
        %{
          username: "user1",
          attribute: "Cleartext-Password",
          op: ":=",
          value: "pass1",
          customer: user1_customer,
          expire_on: ~U[2023-12-31 23:59:59Z],
          service: "ppp"
        },
        %{
          username: "user2",
          attribute: "Cleartext-Password",
          op: ":=",
          value: "pass2",
          customer: user2_customer,
          expire_on: ~U[2023-12-31 23:59:59Z],
          service: "ppp"
        }
      ])

      assert Repo.aggregate(Radcheck, :count, :id) == 2

      # Perform logout for customer1
      assert {:ok, :ok} = Ppoe.logout(user1_customer)

      # Verify only customer1's entry is removed
      assert Repo.aggregate(Radcheck, :count, :id) == 1
      assert Repo.get_by(Radcheck, customer: user2_customer) != nil
    end
  end
end
