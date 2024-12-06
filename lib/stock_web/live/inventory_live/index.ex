defmodule StockWeb.InventoryLive.Index do
  use StockWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.card class="p-4 rounded-xl">
      <div class="flex justify-between">
        <div class="flex text-xl font-bold items-center text-middle justify-center align-middle">
          Inventário
        </div>
        <.link patch={~p"/inventory/new"}>
          <.button class="text-lg" size="small">
            <.icon name="fa-add" /> Adicionar Produtos
          </.button>
        </.link>
      </div>
      <.table>
        <:header>Produto</:header>
        <:header>Quantidade</:header>
        <:header>Descrição</:header>
        <:header>Compras</:header>
        <:header>Excluir</:header>
        <%!-- <%= for {_, customer} <- @streams.customers do %>
          <.tr>
            <.td><%= customer.name %></.td>
            <.td><%= customer.email %></.td>
            <.td><%= customer.phone %></.td>
            <.td>
              Número de Compras
              <.button class="ml-2" size="small">
                <.icon name="fa-eye" />
              </.button>
            </.td>
            <.td>
              <.button size="small">
                <.icon name="fa-x" />
              </.button>
            </.td>
          </.tr>
        <% end %> --%>
      </.table>
    </.card>
    <.modal
      :if={@live_action == :new}
      id="new-customer-modal"
      show
      class="rounded-xl"
      on_cancel={JS.patch(~p"/inventory")}
      title="Adicionar Cliente"
    >
      <.live_component
        module={StockWeb.InventoryLive.New}
        id="new-customer"
        patch={~p"/inventory/new"}
      />
    </.modal>
    """
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply,
     socket
  }
  end
end
