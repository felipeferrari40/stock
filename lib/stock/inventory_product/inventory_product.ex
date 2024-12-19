defmodule Stock.Inventory.InventoryProduct do
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

  schema "inventory" do
    field :quantity, :integer
    field :last_update, :utc_datetime
    
    belongs_to :product, Stock.Products.Product
    
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(inventory_product, attrs) do
    inventory_product
    |> cast(attrs, [:quantity, :last_update, :product_id])
    |> validate_required([:quantity, :product_id])
  end
end
