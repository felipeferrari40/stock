defmodule StockWeb.InventoryLive.New do
  use StockWeb, :live_component

  alias Stock.InventoryMovements
  alias Stock.InventoryMovements.InventoryMovement

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        id="inventory-movement-form"
        phx-change="validate"
        phx-submit="save"
        phx-target={@myself}
        class="space-y-2"
      >
        <div class="grid grid-cols-2 gap-4">
          <.input
            field={@form[:product_id]}
            type="select"
            label="Produtos"
            prompt="Selecione um Produto"
            options={@products}
          />
          <.input
            field={@form[:movement_type]}
            type="select"
            label="Tipo de Movimentação"
            options={[{"Aquisição (Entrada)", :purchase}]}
          />

          <.input field={@form[:quantity]} label="Quantidade" type="number" min="1" x-data />
        </div>
        <button
          class="border-1 border-zinc-900 rounded-xl p-2 text-xl bg-white font-bold hover:bg-black hover:text-white"
          type="submit"
        >
          Salvar
        </button>
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    changeset = InventoryMovements.change_inventory_movement(%InventoryMovement{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign_products()
     |> assign_form(changeset)}
  end

  defp assign_products(socket) do
    with {:ok, {products, _meta}} <- Stock.Products.list_products() do
      products =
        products
        |> Enum.map(&{&1.name, &1.id})

      socket
      |> assign(products: products)
    end
  end

  @impl true
  def handle_event("validate", %{"inventory_movement" => movement_params}, socket) do
    changeset =
      %InventoryMovement{}
      |> InventoryMovements.change_inventory_movement(movement_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"inventory_movement" => movement_params}, socket) do
    case InventoryMovements.create_inventory_movement(movement_params) |> IO.inspect() do
      {:ok, _inventory_movement} ->
        {:noreply,
         socket
         |> put_flash(:info, "Movimentação realizada com sucesso!")
         |> push_navigate(to: "/inventory")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(
      socket,
      :form,
      to_form(changeset)
    )
  end
end
