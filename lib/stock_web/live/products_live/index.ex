defmodule StockWeb.ProductsLive.Index do
  use StockWeb, :live_view

  alias Stock.Products

  @impl true
  def render(assigns) do
    ~H"""
    <.card class="p-4 rounded-xl">
      <div class="flex justify-between">
        <div class="flex text-xl font-bold items-center text-middle justify-center align-middle">
          Produtos
        </div>
        <.link patch={~p"/products/new"}>
          <.button class="text-lg" size="small">
            <.icon name="fa-add" /> Adicionar Produtos
          </.button>
        </.link>
      </div>
      <.table>
        <:header>Nome</:header>
        <:header>Descrição</:header>
        <:header>Preço</:header>
        <:header>Ações</:header>
        <%= for {_, product} <- @streams.products do %>
          <.tr>
            <.td><%= product.name %></.td>
            <.td><%= product.description %></.td>
            <.td><%= Number.Currency.number_to_currency(product.price) %></.td>
            <.td>
              <.link patch={~p"/products/#{product.id}"}>
                <.button class="text-lg" size="small">
                  <.icon name="fa-edit" />
                </.button>
              </.link>
              <.button size="small" phx-click="delete_product" value={product.id}>
                <.icon name="fa-x" />
              </.button>
            </.td>
          </.tr>
        <% end %>
      </.table>
      <div class="mt- flex justify-center">
        <.pagination meta={@meta} path={~p"/products?#{@filters}"} />
      </div>
    </.card>
    <.modal
      :if={@live_action == :new}
      id="new-product-modal"
      show
      class="rounded-xl"
      on_cancel={JS.patch(~p"/products")}
      title="Adicionar Produto"
    >
      <.live_component module={StockWeb.ProductsLive.New} id="new-product" />
    </.modal>
    <.modal
      :if={@live_action == :edit}
      id="edit-product-modal"
      show
      class="rounded-xl"
      on_cancel={JS.patch(~p"/products")}
      title="Adicionar Produto"
    >
      <.live_component
        module={StockWeb.ProductsLive.FormComponent}
        id="edit-product"
        product_id={@product_id}
      />
    </.modal>
    """
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)
     |> assign_products(params)
     |> assign(:filters, params)
     |> assign(:page_title, "Produtos")}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Novo Produto")
  end

  defp apply_action(socket, :edit, params) do
    socket
    |> assign(product_id: params["id"])
    |> assign(:page_title, "Editar Produto")
  end

  defp apply_action(socket, _action, _params) do
    socket
  end

  @impl true
  def handle_event("delete_product", %{"value" => product_id}, socket) do
    case Products.delete_product_by_id(product_id) do
      {:ok, _product} ->
        {:noreply,
         socket
         |> put_flash(:info, "Produto excluído com sucesso!")
         |> push_navigate(to: "/products")}

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

  def assign_products(socket, params) do
    case Products.list_products(params) do
      {:ok, {products, meta}} ->
        socket
        |> assign(meta: meta)
        |> stream(:products, products, reset: true)

      {:error, _meta} ->
        put_flash(socket, :error, "Erro ao recuperar a lista")
    end
  end
end
