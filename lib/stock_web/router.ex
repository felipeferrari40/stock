defmodule StockWeb.Router do
  use StockWeb, :router

  import StockWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {StockWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  if Application.compile_env(:stock, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: StockWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", StockWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{StockWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      get "/", PageController, :home

      live "/register", UserRegistrationLive, :new
      live "/log_in", UserLoginLive, :new
      live "/reset_password", UserForgotPasswordLive, :new
      live "/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/log_in", UserSessionController, :create
  end

  scope "/", StockWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{StockWeb.UserAuth, :ensure_authenticated}] do
      live "/sales", SalesLive.Index
      live "/sales/new", SalesLive.Index, :new
      live "/sales/:id", SalesLive.Index, :edit
      live "/customers", CustomersLive.Index
      live "/customers/new", CustomersLive.Index, :new
      live "/customers/:id/sales", CustomersLive.Index, :show
      live "/products", ProductsLive.Index
      live "/products/new", ProductsLive.Index, :new
      live "/products/:id", ProductsLive.Index, :edit
      live "/inventory", InventoryLive.Index
      live "/inventory/new", InventoryLive.Index, :new
      live "/settings", UserSettingsLive, :edit
      live "/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", StockWeb do
    pipe_through [:browser]

    delete "/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{StockWeb.UserAuth, :mount_current_user}] do
      live "/confirm/:token", UserConfirmationLive, :edit
      live "/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
