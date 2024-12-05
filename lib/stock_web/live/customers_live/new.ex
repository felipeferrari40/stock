defmodule StockWeb.CustomersLive.New do
  use StockWeb, :live_component

  alias Stock.Customers
  alias Stock.Customers.Customer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} id="customer-form" phx-change="validate" phx-submit="save" class="space-y-2">
        <.input field={@form[:name]} label="Nome/Razão Social" />
        <.input field={@form[:email]} type="email" label="E-mail" />
        <.input
          field={@form[:phone]}
          label="Telefone"
          x-data
          x-mask:dynamic="$input.length <= 14 ? '(99) 9999-9999' : '(99) 99999-9999'"
        />
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
    changeset = Customers.change_customer(%Customer{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(
      socket,
      :form,
      to_form(changeset)
    )
  end
end
