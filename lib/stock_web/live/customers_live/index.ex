defmodule StockWeb.CustomersLive.Index do
  use StockWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      teste index customers
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
