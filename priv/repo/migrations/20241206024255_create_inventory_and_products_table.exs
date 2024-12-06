defmodule Stock.Repo.Migrations.CreateInventoryAndProductsTable do
  use Ecto.Migration

  def change do
    create table(:products, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :string
      add :price, :decimal, null: false
      add :unit_of_measure, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create table(:inventory, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :product_id, references(:products, on_delete: :delete_all, type: :binary_id)
      add :quantity, :integer, default: 0, null: false
      add :last_update, :utc_datetime, null: false
      
      timestamps(type: :utc_datetime)
    end

    create index(:inventory, [:product_id])
  end
end
