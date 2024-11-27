defmodule Stock.Repo do
  use Ecto.Repo,
    otp_app: :stock,
    adapter: Ecto.Adapters.Postgres
end
