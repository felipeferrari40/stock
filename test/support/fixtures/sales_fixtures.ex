defmodule Stock.SalesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Stock.Sales` context.
  """

  @doc """
  Generate a sale.
  """
  def sale_fixture(attrs \\ %{}) do
    {:ok, sale} =
      attrs
      |> Enum.into(%{
        status: "some status"
      })
      |> Stock.Sales.create_sale()

    sale
  end
end
