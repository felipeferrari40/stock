defmodule Stock.InventoryMovements do
  @moduledoc """
  The InventoryMovements context.
  """

  import Ecto.Query, warn: false
  alias Stock.Repo

  alias Stock.InventoryMovements.InventoryMovement
  alias Stock.Inventory

  @doc """
  Returns the list of inventory_movement.

  ## Examples

      iex> list_inventory_movement()
      [%InventoryMovement{}, ...]

  """
  def list_inventory_movement(params \\ %{}) do
    query =
      from im in InventoryMovement,
        join: p in assoc(im, :product)

    query
    |> filter_where(params)
    |> Flop.validate_and_run(params, for: InventoryMovement)
  end

  defp filter_where(query, params) do
    Enum.reduce(params, query, fn
      {"query", value}, query ->
        value = "%#{value}%"
        where(query, [im, p], ilike(p.name, ^value))

      {_, _}, query ->
        query
    end)
  end

  @doc """
  Gets a single inventory_movement.

  Raises `Ecto.NoResultsError` if the Inventory movement does not exist.

  ## Examples

      iex> get_inventory_movement!(123)
      %InventoryMovement{}

      iex> get_inventory_movement!(456)
      ** (Ecto.NoResultsError)

  """
  def get_inventory_movement!(id), do: Repo.get!(InventoryMovement, id)

  @doc """
  Creates a inventory_movement.

  ## Examples

      iex> create_inventory_movement(%{field: value})
      {:ok, %InventoryMovement{}}

      iex> create_inventory_movement(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_inventory_movement(attrs) do
    with inventory_movement <-
           %InventoryMovement{}
           |> InventoryMovement.changeset(attrs)
           |> Repo.insert!() do
      Inventory.update_inventory_quantity(inventory_movement)
      {:ok, inventory_movement}
    end
  end

  @doc """
  Updates a inventory_movement.

  ## Examples

      iex> update_inventory_movement(inventory_movement, %{field: new_value})
      {:ok, %InventoryMovement{}}

      iex> update_inventory_movement(inventory_movement, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_inventory_movement(%InventoryMovement{} = inventory_movement, attrs) do
    inventory_movement
    |> InventoryMovement.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a inventory_movement.

  ## Examples

      iex> delete_inventory_movement(inventory_movement)
      {:ok, %InventoryMovement{}}

      iex> delete_inventory_movement(inventory_movement)
      {:error, %Ecto.Changeset{}}

  """
  def delete_inventory_movement(%InventoryMovement{} = inventory_movement) do
    Repo.delete(inventory_movement)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking inventory_movement changes.

  ## Examples

      iex> change_inventory_movement(inventory_movement)
      %Ecto.Changeset{data: %InventoryMovement{}}

  """
  def change_inventory_movement(%InventoryMovement{} = inventory_movement, attrs \\ %{}) do
    InventoryMovement.changeset(inventory_movement, attrs)
  end
end
