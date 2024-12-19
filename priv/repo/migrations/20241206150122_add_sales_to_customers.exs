defmodule Stock.Repo.Migrations.AddSalesToCustomers do
  use Ecto.Migration

  def change do
    alter table(:sales) do
      add :customer_id, references(:customers, on_delete: :nothing, type: :binary_id)
    end
  end
end
