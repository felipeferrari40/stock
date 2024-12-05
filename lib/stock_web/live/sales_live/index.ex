defmodule StockWeb.SalesLive.Index do
  use StockWeb, :live_view

  def render(assigns) do
    ~H"""
    <div>
      teste index sales
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
