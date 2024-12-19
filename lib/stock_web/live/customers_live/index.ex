defmodule StockWeb.CustomersLive.Index do
  use StockWeb, :live_view

  alias Stock.Customers

  alias Stock.Sales

  @impl true
  def render(assigns) do
    ~H"""
    <.card class="p-4 rounded-xl">
      <div class="flex justify-between">
        <div class="flex text-xl font-bold items-center text-middle justify-center align-middle">
          Clientes
        </div>
        <.link patch={~p"/customers/new"}>
          <.button class="text-lg" size="small">
            <.icon name="fa-add" /> Adicionar Clientes
          </.button>
        </.link>
      </div>
      <.table>
        <:header>Nome</:header>
        <:header>Email</:header>
        <:header>Telefone</:header>
        <:header>Compras</:header>
        <:header>Excluir</:header>
        <%= for {_, customer} <- @streams.customers do %>
          <.tr>
            <.td><%= customer.name %></.td>
            <.td><%= customer.email %></.td>
            <.td><%= customer.phone %></.td>
            <.td>
              <.link patch={~p"/customers/#{customer.id}/sales"}>
                <.icon name="fa-eye" />
              </.link>
            </.td>
            <.td>
              <.button phx-click="delete_customer" value={customer.id} size="small">
                <.icon name="fa-x" />
              </.button>
            </.td>
          </.tr>
        <% end %>
      </.table>
      <div class="mt-8 flex justify-center">
        <.pagination meta={@meta} path={~p"/inventory?#{@filters}"} />
      </div>
    </.card>
    <.modal
      :if={@live_action == :new}
      id="new-customer-modal"
      show
      class="rounded-xl"
      on_cancel={JS.patch(~p"/customers")}
      title="Adicionar Cliente"
    >
      <.live_component
        module={StockWeb.CustomersLive.New}
        id="new-customer"
        patch={~p"/customers/new"}
      />
    </.modal>
    <.modal
      :if={@live_action == :show}
      id="customer-modal"
      show
      class="rounded-xl"
      on_cancel={JS.patch(~p"/customers")}
      title="Compras do Cliente"
    >
      <.live_component
        module={StockWeb.CustomersLive.Show}
        id="show-customer"
        sales={@sales}
        patch={~p"/customers/new"}
      />
    </.modal>
    """
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)
     |> assign_customers(params)
     |> assign(:filters, params)
     |> assign(:page_title, "Listar clientes")}
  end

  def assign_customers(socket, params) do
    case Customers.list_customers(params) do
      {:ok, {customers, meta}} ->
        socket
        |> assign(meta: meta)
        |> stream(:customers, customers, reset: true)

      {:error, _meta} ->
        put_flash(socket, :error, "Erro ao recuperar a lista")
    end
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Novo Cliente")
  end

  defp apply_action(socket, :show, params) do
    case Sales.list_sales(params) do
      {:ok, {sales, meta}} ->
        socket
        |> assign(:sales, sales)
        |> assign(meta: meta)
        |> assign(:page_title, "Compras Cliente")

      {:error, _meta} ->
        put_flash(socket, :error, "Erro ao recuperar a lista")
    end
  end

  defp apply_action(socket, _action, _params) do
    socket
  end

  @impl true
  def handle_event("delete_customer", %{"value" => customer_id}, socket) do
    case Customers.delete_customer_by_id(customer_id) do
      {:ok, _product} ->
        {:noreply,
         socket
         |> put_flash(:info, "Cliente excluído com sucesso!")
         |> push_navigate(to: "/customers")}

      {:error, changeset} ->
        errors =
          changeset.errors
          |> Enum.map(&"#{elem(&1, 0)}: #{elem(elem(&1, 1), 0)}")
          |> Enum.join(", ")

        {:noreply,
         socket
         |> put_flash(:error, "#{errors}")}
    end
  end
end
