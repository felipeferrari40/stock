defmodule Stock.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Stock.Products` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{

      })
      |> Stock.Products.create_product()

    product
  end
end
