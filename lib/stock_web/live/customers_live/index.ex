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
        <.button class="text-md bg-[#696969] text-white">
        <.icon name="fa-add" />
          Adicionar Clientes
        </.button>
      </div>
      <.table>
        <:header>Name</:header>
        <:header>Age</:header>
        <:header>Address</:header>
        <:header>Email</:header>
        <:header>Job</:header>
        <:header>Action</:header>

        <.tr>
          <.td>Jim Emerald</.td>
          <.td>27</.td>
          <.td>London No. 1 Lake Park</.td>
          <.td>test@mail.com</.td>
          <.td>Frontend Developer</.td>
          <.td><.rating select={3} count={5} /></.td>
        </.tr>

        <.tr>
          <.td>Alex Brown</.td>
          <.td>32</.td>
          <.td>New York No. 2 River Park</.td>
          <.td>alex@mail.com</.td>
          <.td>Backend Developer</.td>
          <.td><.rating select={4} count={5} /></.td>
        </.tr>

        <.tr>
          <.td>John Doe</.td>
          <.td>28</.td>
          <.td>Los Angeles No. 3 Sunset Boulevard</.td>
          <.td>john@mail.com</.td>
          <.td>UI/UX Designer</.td>
          <.td><.rating select={5} count={5} /></.td>
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
