defmodule StockWeb.Router do
  use StockWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {StockWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", StockWeb do
    live_session :public, root_layout: {StockWeb.Layouts, :root} do
      pipe_through :browser
  
      get "/", PageController, :home
      live "/login", UserLoginLive.Show
      live "/sales", SalesLive.Index
      live "/customers", CustomersLive.Index
      live "/inventary", InventaryLive.Index
    end
  end
  

  if Application.compile_env(:stock, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: StockWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
