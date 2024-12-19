defmodule StockWeb.ProductsLive.New do
  use StockWeb, :live_component

  alias Stock.Products
  alias Stock.Products.Product

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} id="product-form" phx-change="validate" phx-submit="save" class="space-y-2" phx-target={@myself}>
        <div class="grid grid-cols-2 gap-4">
          <.input field={@form[:name]} label="Nome do Produto" placeholder="Ex: Vinho" />
          <.input field={@form[:description]} label="Descrição adicional*" />
          <.input
            field={@form[:price]}
            label="Preço"
            x-data
            placeholder="00.00"
            x-mask:dynamic="$money($input)"
          />
          <.input
            field={@form[:unit_of_measure]}
            type="select"
            options={[{"Peso (Kg, mg)", :weight}, {"Unidade", :unity}]}
            label="Unidade de Medida"
          />
        </div>
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
    changeset = Products.change_product(%Product{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"product" => product_params}, socket) do
    changeset =
      %Product{}
      |> Products.change_product(product_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"product" => product_params}, socket) do
    product_params =
      product_params
      |> Map.update!("price", &Decimal.new(&1))

    case Products.create_product(product_params) do
      {:ok, product} ->
        Stock.Inventory.create_inventory_product(%{
          "quantity" => 0,
          "last_update" => DateTime.utc_now(),
          "product_id" => product.id
        })

        {:noreply,
         socket
         |> put_flash(:info, "Produto adicionado com sucesso!")
         |> push_navigate(to: "/products")}

      {:error, changeset} ->
        errors =
          changeset.errors
          |> Enum.map(&"#{elem(&1, 0)}: #{elem(elem(&1, 1), 0)}")
          |> Enum.join(", ")

        {:noreply,
         socket
         |> put_flash(:error, "#{errors}")
         |> assign_form(changeset)}
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
