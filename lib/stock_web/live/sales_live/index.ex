defmodule StockWeb.SalesLive.Index do
  use StockWeb, :live_view

  alias Stock.Sales

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <.card>
        <.card_title class="flex justify-between">
          Vendas
          <.link patch={~p"/sales/new"}>
            <.button class="text-lg" size="small">
              <.icon name="fa-add" /> Criar Venda
            </.button>
          </.link>
        </.card_title>
        <.table variant="stripped">
          <:header>Cliente</:header>
          <:header>Email</:header>
          <:header>Telefone</:header>
          <:header>Data da Venda</:header>
          <:header>Itens</:header>
          <:header>Total</:header>
          <:header>Status</:header>
          <%= for {_, sale} <- @streams.sales do %>
            <.tr>
              <.td><%= sale.customer.name %></.td>
              <.td><%= sale.customer.email %></.td>
              <.td><%= sale.customer.phone %></.td>
              <.td><%= Calendar.strftime(sale.sale_date, "%d/%m/%Y") %></.td>
              <.td class="space-y-3">
                <%= for item <- sale.sale_items do %>
                  <div class="grid grid-rows-2 gap-1">
                    <div>
                      <span class="font-semibold">Item: </span>
                      <%= item.product_name %>
                    </div>
                    <div>
                      <span class="font-semibold">Qtde.:</span>
                      <%= item.quantity %>
                    </div>
                  </div>
                <% end %>
              </.td>
              <.td><%= Number.Currency.number_to_currency(sale.total_amount) %></.td>
              <.td>
                <%= translate_enum(sale.status) %>
                <.link :if={!sale.status in [:canceled, :delivered]} patch={~p"/sales/#{sale.id}"}>
                  <.button class="ml-2" size="small">
                    <.icon name="fa-edit" />
                  </.button>
                </.link>
              </.td>
            </.tr>
          <% end %>
        </.table>
      </.card>
      <div class="mt- flex justify-center">
        <.pagination meta={@meta} path={~p"/sales?#{@filters}"} />
      </div>
    </div>
    <.modal
      :if={@live_action == :new}
      id="create-sale-modal"
      show
      class="rounded-xl"
      on_cancel={JS.patch(~p"/sales")}
      title="Adicionar Venda"
    >
      <.live_component module={StockWeb.SalesLive.New} id="new-sale" patch={~p"/sales/new"} />
    </.modal>
    <.modal
      :if={@live_action == :edit}
      id="edit-sale-status-modal"
      show
      class="rounded-xl"
      on_cancel={JS.patch(~p"/sales/")}
      title="Alterar Status da Venda"
    >
      <.live_component
        module={StockWeb.SalesLive.FormComponent}
        id="change-status"
        sale_id={@sale_id}
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
     |> assign_sales(params)
     |> assign(:page_title, "Vendas")}
  end

  def assign_sales(socket, params) do
    case Sales.list_sales(params) do
      {:ok, {sales, meta}} ->
        sales = sales |> Stock.Repo.preload(:customer, sale_items: :product)

        socket
        |> assign(meta: meta)
        |> stream(:sales, sales, reset: true)

      {:error, _meta} ->
        put_flash(socket, :error, "Erro ao recuperar a lista")
    end
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Nova Venda")
  end

  defp apply_action(socket, :edit, params) do
    socket
    |> assign(sale_id: params["id"])
    |> assign(:page_title, "Editar Venda")
  end

  defp apply_action(socket, _action, _params) do
    socket
  end
end
