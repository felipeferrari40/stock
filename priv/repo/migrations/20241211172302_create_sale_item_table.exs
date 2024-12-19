defmodule Stock.Repo.Migrations.CreateSaleItemsTable do
  use Ecto.Migration

  def change do
    create table(:sale_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      
      add :sale_id, references(:sales, type: :binary_id, on_delete: :nothing), null: false
      add :product_id, references(:products, type: :binary_id, on_delete: :nothing), null: false

      add :quantity, :integer, default: 1, null: false
      add :unit_price, :decimal, precision: 10, scale: 2, null: false
      add :subtotal, :decimal, precision: 10, scale: 2, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
