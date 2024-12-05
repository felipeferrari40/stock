defmodule Stock.Sales.Sale do
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

  schema "sales" do
    field :status, Ecto.Enum,
      values: [active: 0, canceled: 1, suspended: 2, abandoned_cart: 3, pending: 4]

    field :sale_date, :utc_datetime
    field :total_amount, :decimal

    belongs_to :customers, Stock.Customers.Customer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(sale, attrs) do
    sale
    |> cast(attrs, [:status, :sale_date, :total_amount])
    |> validate_required([:status, :sale_date, :total_amount])
  end
end
