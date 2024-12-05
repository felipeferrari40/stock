defmodule StockWeb.PageController do
  use StockWeb, :controller
  import Plug.Conn

  alias StockWeb.Router.Helpers, as: Routes

  def home(conn, _params) do
    case get_session(conn, :user_id) do
      nil ->
        redirect(conn, to: Routes.live_path(conn, StockWeb.CustomersLive.Index))
      
      _user_id ->
        redirect(conn, to: Routes.live_path(conn, StockWeb.SalesLive.Index))
    end
  end
end
