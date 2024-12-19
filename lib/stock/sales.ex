defmodule Stock.Sales do
  @moduledoc """
  The Sales context.
  """

  import Ecto.Query, warn: false
  alias Stock.Repo

  alias Stock.Sales.Sale
  alias Stock.Sales.SaleItem
  alias Stock.InventoryMovements
  alias Stock.InventoryMovements.InventoryMovement

  @doc """
  Returns the list of sales.

  ## Examples

      iex> list_sales()
      [%Sale{}, ...]

  """
  def list_sales(params \\ %{}) do
    query =
      from s in Sale,
        join: c in assoc(s, :customer)

    query
    |> filter_where(params)
    |> Flop.validate_and_run(params, for: Sale)
  end

  defp filter_where(query, params) do
    Enum.reduce(params, query, fn
      {"query", value}, query ->
        value = "%#{value}%"
        where(query, [s, c], ilike(c.name, ^value))

      {_, _}, query ->
        query
    end)
  end

  @doc """
  Gets a single sale.

  Raises `Ecto.NoResultsError` if the Sale does not exist.

  ## Examples

      iex> get_sale!(123)
      %Sale{}

      iex> get_sale!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sale!(id), do: Repo.get!(Sale, id)

  @doc """
  Creates a sale.

  ## Examples

      iex> create_sale(%{field: value})
      {:ok, %Sale{}}

      iex> create_sale(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sale(attrs \\ %{}) do
    attrs =
      attrs
      |> Map.put("status", "pending")

    Repo.transaction(fn ->
      sale =
        %Sale{}
        |> Sale.changeset(attrs)
        |> Repo.insert!()

      sale
      |> create_inventory_movements()
    end)
  end

  defp create_inventory_movements(%Sale{
         sale_items: sale_items,
         id: sale_id,
         inserted_at: inserted_at
       }) do
    sale_items
    |> Enum.each(fn %SaleItem{product_id: product_id, quantity: quantity} ->
      params = %{
        product_id: product_id,
        quantity: quantity,
        related_id: sale_id,
        movement_type: :sale,
        last_updated: inserted_at
      }

      case InventoryMovements.create_inventory_movement(params) do
        {:ok, _movement} ->
          :ok

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  @doc """
  Updates a sale.

  ## Examples

      iex> update_sale(sale, %{field: new_value})
      {:ok, %Sale{}}

      iex> update_sale(sale, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def update_sale(%Sale{} = sale, %{"status" => "canceled"} = attrs) do
    Repo.transaction(fn ->
      with :ok <- undo_inventory_movements(sale) do
        sale
        |> Sale.changeset(attrs)
        |> Repo.update()
      end
    end)
  end

  def update_sale(%Sale{} = sale, attrs) do
    Repo.transaction(fn ->
      if sale.status in [:canceled , :delivered] do
        Repo.rollback("Não é possível alterar uma venda com status Cancelado")
      else
        sale
        |> Sale.changeset(attrs)
        |> Repo.update()
      end
    end)
  end

  defp undo_inventory_movements(sale) do
    movements =
      Repo.all(
        from im in InventoryMovement,
          where: im.related_id == ^sale.id and im.movement_type == :sale
      )

    Enum.each(movements, fn movement ->
      params = %{
        product_id: movement.product_id,
        quantity: movement.quantity,
        related_id: sale.id,
        movement_type: :sale_reversal,
        last_updated: NaiveDateTime.utc_now()
      }

      case InventoryMovements.create_inventory_movement(params) do
        {:ok, movement} ->
          {:ok, movement}

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  @doc """
  Deletes a sale.

  ## Examples

      iex> delete_sale(sale)
      {:ok, %Sale{}}

      iex> delete_sale(sale)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sale(%Sale{} = sale) do
    Repo.delete(sale)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sale changes.

  ## Examples

      iex> change_sale(sale)
      %Ecto.Changeset{data: %Sale{}}

  """
  def change_sale(%Sale{} = sale, attrs \\ %{}) do
    Sale.changeset(sale, attrs)
  end

  def change_sale_item(%SaleItem{} = sale_item, attrs \\ %{}) do
    SaleItem.changeset(sale_item, attrs)
  end
end
