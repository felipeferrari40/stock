defmodule StockWeb.UserLoginLive do
  use StockWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.card>
        <.header>
          Login do administrador
        </.header>
        <.simple_form for={@form} id="login_form" action={~p"/log_in"} phx-update="ignore">
          <.input field={@form[:email]} label="Email" type="email" required />
          <.input field={@form[:password]} label="Senha" type="password" required />
          <:actions>
            <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          </:actions>
          <:actions>
            <.button phx-disable-with="Logging in..." class="w-full">
              Log in <span aria-hidden="true">→</span>
            </.button>
          </:actions>
        </.simple_form>
      </.card>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end