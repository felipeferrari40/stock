defmodule StockWeb.CustomersLive.New do
  use StockWeb, :live_component

  alias Stock.Customers
  alias Stock.Customers.Customer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        id="customer-form"
        phx-change="validate"
        phx-submit="save"
        class="space-y-2"
        phx-target={@myself}
      >
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
