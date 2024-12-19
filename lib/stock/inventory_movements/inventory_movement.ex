defmodule Stock.InventoryMovements.InventoryMovement do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [],
    sortable: [:inserted_at],
    default_limit: 10,
    default_order: %{
      order_by: [:inserted_at],
      order_directions: [:desc]
    }
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "inventory_movements" do
    field :quantity, :integer

    field(:movement_type, Ecto.Enum,
      values: [
        purchase: 0,
        sale: 1,
        sale_reversal: 2
      ]
    )

    belongs_to :product, Stock.Products.Product
    belongs_to :related, Stock.Sales.Sale

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(inventory_movement, attrs) do
    inventory_movement
    |> cast(attrs, [:product_id, :movement_type, :quantity, :related_id])
    |> validate_required([:product_id, :movement_type, :quantity])
  end
end
