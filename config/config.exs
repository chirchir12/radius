# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :radius,
  ecto_repos: [Radius.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :radius, RadiusWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: RadiusWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Radius.PubSub,
  live_view: [signing_salt: "ajOt9y4p"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :radius, Radius.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# oban configuration
config :radius, Oban,
  engine: Oban.Engines.Basic,
  plugins: [
    {Oban.Plugins.Pruner, max_age: 86400},
    {Oban.Plugins.Cron,
     crontab: [
       {"*/5 * * * *", Radius.Auth.SessionDeleteAll, args: %{check_after_in_mins: 5}}
     ]}
  ],
  queues: [
    clear_individual_internet_sessions: 10,
    clear_all_internet_sessions: 10
  ],
  repo: Radius.Repo

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
