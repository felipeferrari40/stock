defmodule Stock.InventoryMovementsTest do
  use Stock.DataCase

  alias Stock.InventoryMovements

  describe "inventory_movement" do
    alias Stock.InventoryMovements.InventoryMovement

    import Stock.InventoryMovementsFixtures

    @invalid_attrs %{}

    test "list_inventory_movement/0 returns all inventory_movement" do
      inventory_movement = inventory_movement_fixture()
      assert InventoryMovements.list_inventory_movement() == [inventory_movement]
    end

    test "get_inventory_movement!/1 returns the inventory_movement with given id" do
      inventory_movement = inventory_movement_fixture()
      assert InventoryMovements.get_inventory_movement!(inventory_movement.id) == inventory_movement
    end

    test "create_inventory_movement/1 with valid data creates a inventory_movement" do
      valid_attrs = %{}

      assert {:ok, %InventoryMovement{} = inventory_movement} = InventoryMovements.create_inventory_movement(valid_attrs)
    end

    test "create_inventory_movement/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = InventoryMovements.create_inventory_movement(@invalid_attrs)
    end

    test "update_inventory_movement/2 with valid data updates the inventory_movement" do
      inventory_movement = inventory_movement_fixture()
      update_attrs = %{}

      assert {:ok, %InventoryMovement{} = inventory_movement} = InventoryMovements.update_inventory_movement(inventory_movement, update_attrs)
    end

    test "update_inventory_movement/2 with invalid data returns error changeset" do
      inventory_movement = inventory_movement_fixture()
      assert {:error, %Ecto.Changeset{}} = InventoryMovements.update_inventory_movement(inventory_movement, @invalid_attrs)
      assert inventory_movement == InventoryMovements.get_inventory_movement!(inventory_movement.id)
    end

    test "delete_inventory_movement/1 deletes the inventory_movement" do
      inventory_movement = inventory_movement_fixture()
      assert {:ok, %InventoryMovement{}} = InventoryMovements.delete_inventory_movement(inventory_movement)
      assert_raise Ecto.NoResultsError, fn -> InventoryMovements.get_inventory_movement!(inventory_movement.id) end
    end

    test "change_inventory_movement/1 returns a inventory_movement changeset" do
      inventory_movement = inventory_movement_fixture()
      assert %Ecto.Changeset{} = InventoryMovements.change_inventory_movement(inventory_movement)
    end
  end
end
