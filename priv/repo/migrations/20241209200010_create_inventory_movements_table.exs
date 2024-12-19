defmodule Stock.Repo.Migrations.CreateInventoryMovementsTable do
  use Ecto.Migration

  def change do
    create table(:inventory_movements, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :product_id, references(:products, on_delete: :delete_all, type: :binary_id)
      add :quantity, :integer, default: 0, null: false
      add :movement_type, :integer, null: false
      add :related_id, references(:sales, type: :binary_id)

      timestamps(type: :utc_datetime)
    end
  end
end
