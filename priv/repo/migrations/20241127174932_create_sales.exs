defmodule Stock.Repo.Migrations.CreateSales do
  use Ecto.Migration

  def change do
    create table(:sales) do
      add :status, :integer
      add :sale_date, :utc_datetime
      add :total_amount, :decimal

      timestamps(type: :utc_datetime)
    end
  end
end
