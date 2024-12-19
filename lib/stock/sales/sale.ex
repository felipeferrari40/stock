defmodule Stock.Sales.Sale do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:status, :sale_date, :total_amount, :customer_id],
    sortable: [:status, :sale_date, :total_amount, :inserted_at],
    default_limit: 5,
    default_order: %{
      order_by: [:inserted_at],
      order_directions: [:desc]
    }
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "sales" do
    field :status, Ecto.Enum, values: [pending: 0, paid: 1, delivered: 2, canceled: 3]

    field :sale_date, :date
    field :total_amount, :decimal

    belongs_to :customer, Stock.Customers.Customer

    embeds_many :sale_items, Stock.Sales.SaleItem, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(sale, attrs) do
    sale
    |> cast(attrs, [:status, :sale_date, :total_amount, :customer_id])
    |> cast_embed(:sale_items,
      required: true,
      sort_param: :items_sort,
      drop_param: :items_drop,
      with: &Stock.Sales.SaleItem.changeset/2
    )
    |> validate_required([:customer_id])
    |> validate_unique_product_ids()
  end

  defp validate_unique_product_ids(changeset) do
    sale_items = get_field(changeset, :sale_items)

    duplicated_ids =
      if sale_items do
        sale_items
        |> Enum.map(& &1.product_id)
        |> Enum.reject(&is_nil/1)
        |> Enum.frequencies()
        |> Enum.filter(fn {_id, count} -> count > 1 end)
        |> Enum.map(&elem(&1, 0))
      end

    if duplicated_ids == [] do
      changeset
    else
      add_error(changeset, :status, "Itens duplicados encontrados")
    end
  end
end
