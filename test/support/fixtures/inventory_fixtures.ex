defmodule Stock.InventoryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Stock.Inventory` context.
  """

  @doc """
  Generate a inventory_product.
  """
  def inventory_product_fixture(attrs \\ %{}) do
    {:ok, inventory_product} =
      attrs
      |> Enum.into(%{

      })
      |> Stock.Inventory.create_inventory_product()

    inventory_product
  end
end
