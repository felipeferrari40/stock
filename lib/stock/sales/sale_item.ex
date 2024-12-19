defmodule Stock.Sales.SaleItem do
  use Ecto.Schema
  import Ecto.Changeset

  alias Stock.Products.Product

  embedded_schema do
    field :quantity, :integer
    field :unit_price, :decimal
    field :subtotal, :decimal
    field :product_id, :binary_id
    field :product_name, :string
  end

  def changeset(sale_item, attrs) do
    sale_item
    |> cast(attrs, [:product_id, :product_name, :quantity, :unit_price, :subtotal])
    |> validate_required([:product_id, :quantity])
    |> validate_number(:quantity, greater_than: 0)
    |> fetch_unit_price()
    |> calculate_subtotal()
  end

  defp fetch_unit_price(changeset) do
    product_id = get_field(changeset, :product_id)

    if is_nil(product_id) do
      changeset
    else
      case Stock.Products.get_product!(product_id) do
        nil ->
          changeset
          |> add_error(:product_id, "Produto não encontrado")

        %Product{price: unit_price, name: product_name} ->
          unit_price = "#{unit_price}"

          changeset
          |> put_change(:unit_price, unit_price)
          |> put_change(:product_name, product_name)
      end
    end
  end

  defp calculate_subtotal(changeset) do
    quantity = get_field(changeset, :quantity)
    unit_price = get_field(changeset, :unit_price)

    if quantity && unit_price do
      unit_price =
        if String.contains?(unit_price, ".") do
          String.to_float(unit_price)
        else
          String.to_float("#{unit_price}.00")
        end

      subtotal = quantity * unit_price

      put_change(changeset, :subtotal, subtotal)
    else
      changeset
    end
  end
end
