defmodule StockWeb.CustomersLive.Show do
  use StockWeb, :live_component
  use StockWeb.Components.MishkaComponents

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.table>
        <:header>Status</:header>
        <:header>Data da Venda</:header>
        <:header>Itens</:header>
        <:header>Quantidade</:header>

        <:header>Total</:header>
        <%= for sale <- @sales do %>
          <.tr>
            <.td><%= translate_enum(sale.status) %></.td>
            <.td><%= Calendar.strftime(sale.sale_date, "%d/%m/%Y") %></.td>
            <%= for item <- sale.sale_items do %>
              <.td>
                <%= item.product_name %>
              </.td>
              <.td>
                <%= item.quantity %>
              </.td>
            <% end %>
            <.td><%= Number.Currency.number_to_currency(sale.total_amount) %></.td>
          </.tr>
        <% end %>
      </.table>
    </div>
    """
  end
end
