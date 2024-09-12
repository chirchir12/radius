defmodule Radius.NasTest do
  use Radius.DataCase

  alias Radius.Nas
  alias Radius.Nas.Router

  describe "routers" do
    @valid_attrs %{
      companyid: 42,
      nasname: "some nasname",
      shortname: "some shortname",
      type: "some type",
      ports: 42,
      secret: "some secret",
      server: "some server",
      community: "some community",
      description: "some description"
    }
    @update_attrs %{
      companyid: 43,
      nasname: "updated nasname",
      shortname: "updated shortname",
      type: "updated type",
      ports: 43,
      secret: "updated secret",
      server: "updated server",
      community: "updated community",
      description: "updated description"
    }
    @invalid_attrs %{
      companyid: nil,
      nasname: nil,
      shortname: nil,
      type: nil,
      ports: nil,
      secret: nil,
      server: nil,
      community: nil,
      description: nil
    }

    def router_fixture(attrs \\ %{}) do
      {:ok, router} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Nas.create_router()

      router
    end

    test "list_routers/0 returns all routers" do
      router = router_fixture()
      assert Nas.list_routers() == {:ok, [router]}
    end

    test "list_routers/1 returns routers for a specific company" do
      router1 = router_fixture()
      router2 = router_fixture(%{companyid: 99})

      assert Nas.list_routers(42) == {:ok, [router1]}
      assert Nas.list_routers(99) == {:ok, [router2]}
    end

    test "get_router/1 returns the router with given id" do
      router = router_fixture()
      assert Nas.get_router(router.id) == {:ok, router}
    end

    test "get_router/1 returns error for non-existent router" do
      assert Nas.get_router(0) == {:error, :router_not_found}
    end

    test "create_router/1 with valid data creates a router" do
      assert {:ok, %Router{} = router} = Nas.create_router(@valid_attrs)
      assert router.companyid == 42
      assert router.nasname == "some nasname"
      assert router.shortname == "some shortname"
      assert router.type == "some type"
      assert router.ports == 42
      assert router.secret == "some secret"
      assert router.server == "some server"
      assert router.community == "some community"
      assert router.description == "some description"
    end

    test "create_router/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Nas.create_router(@invalid_attrs)
    end

    test "update_router/2 with valid data updates the router" do
      router = router_fixture()
      assert {:ok, %Router{} = updated_router} = Nas.update_router(router, @update_attrs)
      assert updated_router.companyid == 43
      assert updated_router.nasname == "updated nasname"
      assert updated_router.shortname == "updated shortname"
      assert updated_router.type == "updated type"
      assert updated_router.ports == 43
      assert updated_router.secret == "updated secret"
      assert updated_router.server == "updated server"
      assert updated_router.community == "updated community"
      assert updated_router.description == "updated description"
    end

    test "update_router/2 with invalid data returns error changeset" do
      router = router_fixture()
      assert {:error, %Ecto.Changeset{}} = Nas.update_router(router, @invalid_attrs)
      assert {:ok, ^router} = Nas.get_router(router.id)
    end

    test "delete_router/1 deletes the router" do
      router = router_fixture()
      assert {:ok, %Router{}} = Nas.delete_router(router)
      assert Nas.get_router(router.id) == {:error, :router_not_found}
    end
  end
end
