import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/radius start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.

if System.get_env("RADIUS_PHX_SERVER") do
  config :radius, RadiusWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_url =
    System.get_env("RADIUS_DATABASE_URL") ||
      raise """
      environment variable RADIUS_DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :radius, Radius.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("RADIUS_SECRET_KEY_BASE") ||
      raise """
      environment variable RADIUS_SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("RADIUS_PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("RADIUS_PORT") || "4000")

  config :radius, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :radius, RadiusWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/bandit/Bandit.html#t:options/0
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :radius, RadiusWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your config/prod.exs,
  # ensuring no data is ever sent via http, always redirecting to https:
  #
  #     config :radius, RadiusWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  #     config :radius, Radius.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("MAILGUN_API_KEY"),
  #       domain: System.get_env("MAILGUN_DOMAIN")
  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
end

# auth
system_secret =
  System.get_env("RADIUS_SYSTEM_AUTH_SECRET") || raise("RADIUS_SYSTEM_AUTH_SECRET is not set")

users_secret = System.get_env("RADIUS_AUTH_SECRET") || raise("RADIUS_AUTH_SECRET is not set")

config :radius, Radius.Diralink.Auth,
  system_secret: Joken.Signer.create("HS512", system_secret),
  users_secret: Joken.Signer.create("HS512", users_secret)

# rmq
# MAIN EXCHANGE
exchange_name =
  System.get_env("RMQ_DIRALINK_EXCHANGE") || raise("RMQ_DIRALINK_EXCHANGE is missing")

connection = System.get_env("RMQ_URL") || raise("RMQ_URL environment variable is missing")

# main publisher
config :radius, Radius.RmqPublisher,
  url: connection,
  exchange: exchange_name

# packages consumer
config :radius, Radius.RmqConsumers.PlanConsumer,
  connection: connection,
  exchange: exchange_name,
  deadletter: false,
  queue_options: [
    durable: true
  ],
  queue:
    System.get_env("RMQ_RADIUS_PLAN_CONSUMER") ||
      raise("RMQ_RADIUS_PLAN_CONSUMER environment variable is missing"),
  prefetch_count: "10",
  routing_key:
    System.get_env("RMQ_PLAN_ROUTING_KEY") ||
      raise("RMQ_PLAN_ROUTING_KEY environment variable is missing")

# hotspot subscriptions
config :radius, Radius.RmqConsumers.HotspotSubscriptionConsumer,
  connection: connection,
  exchange: exchange_name,
  deadletter: false,
  queue_options: [
    durable: true
  ],
  queue:
    System.get_env("RMQ_RADIUS_HOTSPOT_SUBSCRIPTION_CONSUMER") ||
      raise("RMQ_RADIUS_HOTSPOT_SUBSCRIPTION_CONSUMER environment variable is missing"),
  prefetch_count: "10",
  routing_key:
    System.get_env("RMQ_HOTSPOT_SUBSCRIPTION_ROUTING_KEY") ||
      raise("RMQ_HOTSPOT_SUBSCRIPTION_ROUTING_KEY environment variable is missing")

# ppoe subscriptions
config :radius, Radius.RmqConsumers.PpoeSubscriptionConsumer,
  connection: connection,
  exchange: exchange_name,
  deadletter: false,
  queue_options: [
    durable: true
  ],
  queue:
    System.get_env("RMQ_RADIUS_PPOE_SUBSCRIPTION_CONSUMER") ||
      raise("RMQ_RADIUS_PPOE_SUBSCRIPTION_CONSUMER environment variable is missing"),
  prefetch_count: "10",
  routing_key:
    System.get_env("RMQ_PPOE_SUBSCRIPTION_ROUTING_KEY") ||
      raise("RMQ_PPOE_SUBSCRIPTION_ROUTING_KEY environment variable is missing")
