defmodule StockWeb.CustomersLive.Index do
  use StockWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.card class="p-4 rounded-xl">
      <div class="flex justify-between">
        <div class="flex text-xl font-bold items-center text-middle justify-center align-middle">
          Clientes
        </div>
        <.link patch={~p"/customers/new"}>
          <.button class="text-lg" size="medium">
            <.icon name="fa-add" /> Adicionar Clientes
          </.button>
        </.link>
      </div>
      <.table>
        <:header>Nome</:header>
        <:header>Email</:header>
        <:header>Telefone</:header>
        <:header>Compras</:header>

        <.tr>
          <.td>Jim Emerald</.td>
          <.td>test@mail.com</.td>
          <.td>(13) 1111-11111</.td>
          <.td>Compras</.td>
        </.tr>
      </.table>
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
    """
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)
     |> assign(:page_title, "Listar clientes")}
  end

  defp apply_action(socket, :new, _params) do
    IO.inspect(">>>>>>>>>>>>>>>>>>>>>>>>>>>")

    
    socket
    |> assign(:page_title, "Novo Cliente")
    
  end

  defp apply_action(socket, _action, _params) do
    socket
  end

  @impl true
  def handle_event("validate", %{"customer" => customer_params}, socket) do
    changeset =
      %Stock.Customers.Customer{}
      |> Stock.Customers.change_customer(customer_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"customer" => customer_params}, socket) do
    case Stock.Customers.create_customer(customer_params) do
      {:ok, _customer} ->
        {:noreply,
         socket
         |> put_flash(:info, "Cliente gerado com sucesso!")
         |> push_navigate(to: "/customers")}

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
