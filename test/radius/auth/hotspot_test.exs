defmodule Radius.Auth.HotspotTest do
  use Radius.DataCase

  alias Radius.Auth.Hotspot
  alias Radius.Auth.Radcheck
  alias Radius.UserGroup.Radusergroup

  describe "login/1" do
    test "successfully creates radcheck and radusergroup entries" do
      attrs = %Hotspot{
        username: "testuser",
        password: "testpass",
        customer: "152b81fd-057e-49d5-8239-c608ee20f3a5",
        service: "hotspot",
        expire_on: ~N[2023-12-31 23:59:59],
        plan: "basic_plan"
      }

      assert {:ok, :ok} = Hotspot.login(attrs)

      # Verify radcheck entry
      radcheck = Repo.get_by(Radcheck, username: "testuser")
      assert radcheck.attribute == "Cleartext-Password"
      assert radcheck.op == "=="
      assert radcheck.value == "testpass"
      assert radcheck.customer == "152b81fd-057e-49d5-8239-c608ee20f3a5"
      assert radcheck.expire_on == ~U[2023-12-31 23:59:59Z]

      # Verify radusergroup entry
      radusergroup = Repo.get_by(Radusergroup, username: "testuser")
      assert radusergroup.groupname == "basic_plan"
      assert radusergroup.customer == "152b81fd-057e-49d5-8239-c608ee20f3a5"
    end

    test "returns error when login fails" do
      attrs = %Hotspot{
        # Invalid username
        username: nil,
        password: "testpass",
        customer: "152b81fd-057e-49d5-8239-c608ee20f3a5",
        service: "hotspot",
        expire_on: ~N[2023-12-31 23:59:59],
        plan: "basic_plan"
      }

      assert {:error, _} = Hotspot.login(attrs)
    end
  end

  describe "logout/1" do
    test "successfully deletes radcheck and radusergroup entries" do
      customer = "152b81fd-057e-49d5-8239-c608ee20f3a5"

      attrs = %Hotspot{
        username: "testuser",
        password: "testpass",
        customer: "152b81fd-057e-49d5-8239-c608ee20f3a5",
        service: "hotspot",
        expire_on: ~N[2023-12-31 23:59:59],
        plan: "basic_plan"
      }

      assert {:ok, :ok} = Hotspot.login(attrs)

      assert {:ok, :ok} = Hotspot.logout(customer)

      assert is_nil(Repo.get_by(Radcheck, customer: customer))
      assert is_nil(Repo.get_by(Radusergroup, customer: customer))
    end

    test "returns error when customer is not found" do
      customer = "152b81fd-057e-49d5-8239-c608ee20f3a5"

      assert {:error, :customer_session_not_found} = Hotspot.logout(customer)
    end
  end
end
