defmodule Stock.SalesTest do
  use Stock.DataCase

  alias Stock.Sales

  describe "sales" do
    alias Stock.Sales.Sale

    import Stock.SalesFixtures

    @invalid_attrs %{status: nil}

    test "list_sales/0 returns all sales" do
      sale = sale_fixture()
      assert Sales.list_sales() == [sale]
    end

    test "get_sale!/1 returns the sale with given id" do
      sale = sale_fixture()
      assert Sales.get_sale!(sale.id) == sale
    end

    test "create_sale/1 with valid data creates a sale" do
      valid_attrs = %{status: "some status"}

      assert {:ok, %Sale{} = sale} = Sales.create_sale(valid_attrs)
      assert sale.status == "some status"
    end

    test "create_sale/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sales.create_sale(@invalid_attrs)
    end

    test "update_sale/2 with valid data updates the sale" do
      sale = sale_fixture()
      update_attrs = %{status: "some updated status"}

      assert {:ok, %Sale{} = sale} = Sales.update_sale(sale, update_attrs)
      assert sale.status == "some updated status"
    end

    test "update_sale/2 with invalid data returns error changeset" do
      sale = sale_fixture()
      assert {:error, %Ecto.Changeset{}} = Sales.update_sale(sale, @invalid_attrs)
      assert sale == Sales.get_sale!(sale.id)
    end

    test "delete_sale/1 deletes the sale" do
      sale = sale_fixture()
      assert {:ok, %Sale{}} = Sales.delete_sale(sale)
      assert_raise Ecto.NoResultsError, fn -> Sales.get_sale!(sale.id) end
    end

    test "change_sale/1 returns a sale changeset" do
      sale = sale_fixture()
      assert %Ecto.Changeset{} = Sales.change_sale(sale)
    end
  end
end
