defmodule Radius.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RadiusWeb.Telemetry,
      Radius.Repo,
      {Oban, Application.fetch_env!(:radius, Oban)},
      {DNSCluster, query: Application.get_env(:radius, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Radius.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Radius.Finch},
      # Start a worker by calling: Radius.Worker.start_link(arg)
      # {Radius.Worker, arg},
      # Start to serve requests, typically the last entry
      RadiusWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Radius.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RadiusWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
