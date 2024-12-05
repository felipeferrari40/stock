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
        <.button class="text-md">
        <.icon name="fa-add" />
          Adicionar Clientes
        </.button>
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
    <.modal id="modal-1" title="Adicionar Cliente">
      <div class="border border-gray-800 p-4 rounded-xl">
        Lorem ipsum dolor sit amet consectetur adipisicing elit.
        Commodi ea atque soluta praesentium quidem dicta sapiente accusamus nihil.
      </div>
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
