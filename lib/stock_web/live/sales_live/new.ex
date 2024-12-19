defmodule StockWeb.SalesLive.New do
  use StockWeb, :live_component

  alias Stock.Sales
  alias Stock.Sales.Sale

  import Ecto.Changeset

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="sale-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="flex gap-4">
          <.input field={@form[:customer_id]} type="select" label="Cliente" options={@customers} />
          <.input field={@form[:sale_date]} type="date" label="Data da Venda" />
          <.input
            label="Status"
            type="select"
            readonly
            disabled
            options={[
              {"Pendente", :pending},
              {"Pago", :paid},
              {"Entregue", :delivered},
              {"Cancelado", :canceled}
            ]}
            field={@form[:status]}
          />
        </div>
        <h2 class="text-lg font-medium text-gray-900">Itens</h2>
        <%= if Enum.empty?(@form[:sale_items].value) do %>
          Nenhum Item Adicionado
        <% end %>
        <.inputs_for :let={sale_item} field={@form[:sale_items]}>
          <input type="hidden" name="sale[items_sort][]" value={sale_item.index} />
          <div class="flex">
            <div class="grid grid-cols-4 gap-4">
              <.input
                field={sale_item[:product_id]}
                type="select"
                label="Produto"
                prompt="Selecione um Produto"
                options={@products}
              />
              <.input field={sale_item[:unit_price]} disabled readonly label="Preço Unitário" />
              <.input
                field={sale_item[:quantity]}
                min="0"
                readonly={!get_available_quantity(sale_item.source)}
                max={get_available_quantity(sale_item.source)}
                type="number"
                label="Quantidade"
              />
              <.input field={sale_item[:subtotal]} disabled readonly label="Subtotal" />
            </div>
            <label class="ml-4 my-auto w-4 h-4 cursor-pointer">
              <input type="checkbox" name="sale[items_drop][]" value={sale_item.index} class="hidden" />
              <.icon name="fa-trash" class="pt-3" />
            </label>
          </div>
        </.inputs_for>
        <:actions>
          <button
            class="border-1 border-zinc-900 rounded-xl p-2 text-xl bg-white font-bold hover:bg-black hover:text-white"
            type="submit"
          >
            Salvar
          </button>
          <label class="py-2 px-3 inline-block cursor-pointer bg-green-500 hover:bg-green-700
            rounded-lg text-center text-white text-sm font-semibold leading-6">
            <input type="checkbox" name="sale[items_sort][]" class="hidden" /> Adicionar Item
          </label>
        </:actions>
        <input type="hidden" name="sale[items_drop][]" />
        <h2 class="font-semibold mt-4 text-lg flex ">
          <.input field={@form[:total_amount]} disabled readonly label="Total" />
        </h2>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    changeset = Sales.change_sale(%Sale{}) |> Ecto.Changeset.cast_embed(:sale_items)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_customers()
     |> assign_products()
     |> assign_form(changeset)}
  end

  defp assign_customers(socket) do
    with {:ok, {customers, _meta}} <- Stock.Customers.list_customers() do
      customers =
        customers
        |> Enum.map(&{&1.name, &1.id})

      socket
      |> assign(customers: customers)
    end
  end

  defp get_available_quantity(changeset) do
    product_id = Ecto.Changeset.get_field(changeset, :product_id)

    cond do
      is_nil(product_id) ->
        0

      inventory = Stock.Inventory.get_inventory_by_product_id!(product_id) ->
        inventory.quantity || 0

      true ->
        0
    end
  end

  defp assign_products(socket) do
    with {:ok, {products, _meta}} <- Stock.Products.list_products() do
      products =
        products
        |> Enum.map(&{&1.name, &1.id})

      socket
      |> assign(products: products)
    end
  end

  @impl true
  def handle_event("validate", %{"sale" => sale_params}, socket) do
    changeset =
      socket.assigns.form.data
      |> Sales.change_sale(sale_params)
      |> Map.put(:action, :validate)

    changeset = calculate_total_amount(changeset)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"sale" => sale_params}, socket) do
    case Sales.create_sale(sale_params) do
      {:ok, sale} ->
        notify_parent({:saved, sale})

        {:noreply,
         socket
         |> put_flash(:info, "Venda gerada com sucesso!")
         |> push_patch(to: ~p"/sales")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp calculate_total_amount(changeset) do
    sale_items = get_field(changeset, :sale_items, [])

    total_amount =
      sale_items
      |> Enum.reduce(0.00, fn %Stock.Sales.SaleItem{subtotal: subtotal}, acc ->
        acc + (subtotal || 0.00)
      end)

    put_change(changeset, :total_amount, total_amount)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    date = Date.to_iso8601(Date.utc_today())

    changeset =
      changeset
      |> Ecto.Changeset.put_change(:sale_date, date)

    assign(socket, :form, to_form(changeset))
  end
end
