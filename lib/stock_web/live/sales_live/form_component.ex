defmodule StockWeb.SalesLive.FormComponent do
  use StockWeb, :live_component

  alias Stock.Sales

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={@form} phx-target={@myself} id="change-sale-status" phx-submit="edit_status">
        <.input
          label="Status"
          type="select"
          options={[
            {"Pendente", :pending},
            {"Pago", :paid},
            {"Entregue", :delivered},
            {"Cancelado", :canceled}
          ]}
          field={@form[:status]}
        />
        <:actions>
        <button
          class="border-1 border-zinc-900 rounded-xl p-2 text-xl bg-white font-bold hover:bg-black hover:text-white"
          type="submit"
        >
          Salvar
        </button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    sale = Sales.get_sale!(assigns.sale_id)
    changeset = Sales.change_sale(sale)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("edit_status", params, socket) do
    sale = Sales.get_sale!(socket.assigns.sale_id)

    case Sales.update_sale(sale, params["sale"]) do
      {:ok, _sale} ->
        {:noreply,
         socket
         |> put_flash(:info, "Status Alterado com Sucesso!")
         |> push_navigate(to: "/sales")}

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
