defmodule Stock.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      StockWeb.Telemetry,
      Stock.Repo,
      {DNSCluster, query: Application.get_env(:stock, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Stock.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Stock.Finch},
      # Start a worker by calling: Stock.Worker.start_link(arg)
      # {Stock.Worker, arg},
      # Start to serve requests, typically the last entry
      StockWeb.Endpoint
    ]
    
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Stock.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    StockWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
