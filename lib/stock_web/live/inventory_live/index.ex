defmodule StockWeb.InventoryLive.Index do
  use StockWeb, :live_view

  alias Stock.Repo

  alias Stock.Inventory
  alias Stock.InventoryMovements

  @impl true
  def render(assigns) do
    ~H"""
    <.card class="p-4 rounded-xl">
      <div class="flex justify-between">
        <div class="flex text-xl font-bold items-center text-middle justify-center align-middle">
          Estoque
        </div>
        <.link patch={~p"/inventory/new"}>
          <.button class="text-lg" size="small">
            <.icon name="fa-add" /> Gerar movimentação
          </.button>
        </.link>
      </div>
      <.table>
        <:header>Produto</:header>
        <:header>Descrição</:header>
        <:header>Quantidade</:header>
        <:header>Última Atualização</:header>

        <%= for {_, inventory_product} <- @streams.inventory do %>
          <.tr>
            <.td><%= inventory_product.product.name %></.td>
            <.td><%= inventory_product.product.description %></.td>

            <.td><%= inventory_product.quantity %></.td>
            <.td><%= Calendar.strftime(inventory_product.last_update, "%d/%m/%Y %H:%M") %></.td>
          </.tr>
        <% end %>
      </.table>
    </.card>
    <.card :if={@streams.inventory_movements != []} class="p-4 mt-8 rounded-xl">
      <div class="flex justify-between">
        <div class="flex text-xl font-bold items-center text-middle justify-center align-middle">
          Histórico de movimentação
        </div>
      </div>
      <.table>
        <:header>Ação</:header>
        <:header>Produto</:header>
        <:header>Quantidade</:header>
        <:header>Data</:header>

        <%= for {_, inventory_movement} <- @streams.inventory_movements do %>
          <.tr>
            <.td><%= translate_enum(inventory_movement.movement_type) %></.td>
            <.td><%= inventory_movement.product.name %></.td>
            <.td><%= inventory_movement.quantity %></.td>
            <.td><%= Calendar.strftime(inventory_movement.inserted_at, "%d/%m/%Y %H:%M") %></.td>
          </.tr>
        <% end %>
      </.table>
      <div class="mt-8 flex justify-center">
        <.pagination meta={@movements_meta} path={~p"/inventory?#{@filters}"} />
      </div>
    </.card>
    <.modal
      :if={@live_action == :new}
      id="add-inventory-modal"
      show
      class="rounded-xl"
      on_cancel={JS.patch(~p"/inventory")}
      title="Gerar Movimentação"
    >
      <.live_component
        module={StockWeb.InventoryLive.New}
        id="new-inventory-movment"
        patch={~p"/inventory/new"}
      />
    </.modal>
    """
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)
     |> assign(:filters, params)
     |> assign_inventory()
     |> assign_inventory_movements(params)
     |> assign(:page_title, "Estoque")}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Movimentação de Inventário")
  end

  defp apply_action(socket, _action, _params) do
    socket
  end

  def assign_inventory(socket) do
    case Inventory.list_inventory() do
      {:ok, {inventory, meta}} ->
        inventory = inventory |> Stock.Repo.preload(:product)

        socket
        |> assign(meta: meta)
        |> stream(:inventory, inventory, reset: true)

      {:error, _meta} ->
        put_flash(socket, :error, "Erro ao recuperar a lista")
    end
  end

  def assign_inventory_movements(socket, params) do
    case InventoryMovements.list_inventory_movement(params) do
      {:ok, {inventory_movements, meta}} ->
        inventory_movements = inventory_movements |> Repo.preload([:product])

        socket
        |> assign(movements_meta: meta)
        |> stream(:inventory_movements, inventory_movements, reset: true)

      {:error, _meta} ->
        put_flash(socket, :error, "Erro ao recuperar a lista")
    end
  end
end
