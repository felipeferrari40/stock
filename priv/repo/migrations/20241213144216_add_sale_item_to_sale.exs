defmodule Stock.Repo.Migrations.AddSaleItemToSale do
  use Ecto.Migration

  def change do
    alter table(:sales) do
      add :sale_items, :map
    end
  end
end
