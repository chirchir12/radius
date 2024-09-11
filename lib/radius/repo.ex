defmodule Radius.Repo do
  use Ecto.Repo,
    otp_app: :radius,
    adapter: Ecto.Adapters.Postgres
end
