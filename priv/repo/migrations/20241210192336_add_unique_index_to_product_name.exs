defmodule Stock.Repo.Migrations.AddUniqueIndexToProductName do
  use Ecto.Migration

  def change do
    create unique_index(:products, [:name])
  end
end
