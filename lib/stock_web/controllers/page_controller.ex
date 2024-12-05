defmodule StockWeb.PageController do
  use StockWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end
end
