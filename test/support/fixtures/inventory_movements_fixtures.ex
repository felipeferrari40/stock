defmodule Stock.InventoryMovementsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Stock.InventoryMovements` context.
  """

  @doc """
  Generate a inventory_movement.
  """
  def inventory_movement_fixture(attrs \\ %{}) do
    {:ok, inventory_movement} =
      attrs
      |> Enum.into(%{

      })
      |> Stock.InventoryMovements.create_inventory_movement()

    inventory_movement
  end
end
