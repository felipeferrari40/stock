defmodule Stock.Inventory do
  @moduledoc """
  The Inventory context.
  """

  import Ecto.Query, warn: false
  alias Stock.Repo

  alias Stock.Inventory
  alias Stock.Inventory.InventoryProduct
  alias Stock.InventoryMovements.InventoryMovement

  @doc """
  Returns the list of inventory.

  ## Examples

      iex> list_inventory()
      [%Inventory_product{}, ...]

  """
  def list_inventory(params \\ %{}) do
    query =
      from ip in InventoryProduct,
        join: p in assoc(ip, :product)

    query
    |> filter_where(params)
    |> Flop.validate_and_run(params, for: InventoryProduct)
  end

  defp filter_where(query, params) do
    Enum.reduce(params, query, fn
      {"query", value}, query ->
        value = "%#{value}%"
        where(query, [u], ilike(u.name, ^value) or ilike(u.description, ^value))

      {_, _}, query ->
        query
    end)
  end

  def update_inventory_quantity(inventory_movement) do
    inventory_product = Inventory.get_inventory_by_product_id!(inventory_movement.product_id)

    new_quantity =
      cond do
        inventory_movement.movement_type in [:sale_reversal, :purchase] ->
          inventory_product.quantity + inventory_movement.quantity

        inventory_movement.movement_type == :sale ->
          inventory_product.quantity - inventory_movement.quantity
      end

    inventory_product
    |> InventoryProduct.changeset(%{quantity: new_quantity})
    |> Repo.update()
  end

  @doc """
  Gets a single inventory_product.

  Raises `Ecto.NoResultsError` if the Inventory product does not exist.

  ## Examples

      iex> get_inventory_product!(123)
      %Inventory_product{}

      iex> get_inventory_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_inventory_product!(id), do: Repo.get!(InventoryProduct, id)

  def get_inventory_by_product_id!(product_id) do
    query =
      from ip in InventoryProduct,
        where: ip.product_id == ^product_id

    Repo.one!(query)
  end

  @doc """
  Creates a inventory_product.

  ## Examples

      iex> create_inventory_product(%{field: value})
      {:ok, %Inventory_product{}}

      iex> create_inventory_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_inventory_product(attrs \\ %{}) do
    %InventoryProduct{}
    |> InventoryProduct.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a inventory_product.

  ## Examples

      iex> update_inventory_product(inventory_product, %{field: new_value})
      {:ok, %Inventory_product{}}

      iex> update_inventory_product(inventory_product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_inventory_product(%InventoryProduct{} = inventory_product, attrs) do
    inventory_product
    |> InventoryProduct.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a inventory_product.

  ## Examples

      iex> delete_inventory_product(inventory_product)
      {:ok, %Inventory_product{}}

      iex> delete_inventory_product(inventory_product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_inventory_product(%InventoryProduct{} = inventory_product) do
    Repo.delete(inventory_product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking inventory_product changes.

  ## Examples

      iex> change_inventory_product(inventory_product)
      %Ecto.Changeset{data: %Inventory_product{}}

  """
  def change_inventory_product(%InventoryProduct{} = inventory_product, attrs \\ %{}) do
    InventoryProduct.changeset(inventory_product, attrs)
  end
end
