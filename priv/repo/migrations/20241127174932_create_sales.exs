defmodule Stock.Repo.Migrations.CreateSales do
  use Ecto.Migration

  def change do
    create table(:sales, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :status, :integer
      add :sale_date, :utc_datetime
      add :total_amount, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
