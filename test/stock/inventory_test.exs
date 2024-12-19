defmodule Stock.InventoryTest do
  use Stock.DataCase

  alias Stock.Inventory

  describe "inventory" do
    alias Stock.Inventory.Inventory_product

    import Stock.InventoryFixtures

    @invalid_attrs %{}

    test "list_inventory/0 returns all inventory" do
      inventory_product = inventory_product_fixture()
      assert Inventory.list_inventory() == [inventory_product]
    end

    test "get_inventory_product!/1 returns the inventory_product with given id" do
      inventory_product = inventory_product_fixture()
      assert Inventory.get_inventory_product!(inventory_product.id) == inventory_product
    end

    test "create_inventory_product/1 with valid data creates a inventory_product" do
      valid_attrs = %{}

      assert {:ok, %Inventory_product{} = inventory_product} = Inventory.create_inventory_product(valid_attrs)
    end

    test "create_inventory_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_inventory_product(@invalid_attrs)
    end

    test "update_inventory_product/2 with valid data updates the inventory_product" do
      inventory_product = inventory_product_fixture()
      update_attrs = %{}

      assert {:ok, %Inventory_product{} = inventory_product} = Inventory.update_inventory_product(inventory_product, update_attrs)
    end

    test "update_inventory_product/2 with invalid data returns error changeset" do
      inventory_product = inventory_product_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_inventory_product(inventory_product, @invalid_attrs)
      assert inventory_product == Inventory.get_inventory_product!(inventory_product.id)
    end

    test "delete_inventory_product/1 deletes the inventory_product" do
      inventory_product = inventory_product_fixture()
      assert {:ok, %Inventory_product{}} = Inventory.delete_inventory_product(inventory_product)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_inventory_product!(inventory_product.id) end
    end

    test "change_inventory_product/1 returns a inventory_product changeset" do
      inventory_product = inventory_product_fixture()
      assert %Ecto.Changeset{} = Inventory.change_inventory_product(inventory_product)
    end
  end
end
