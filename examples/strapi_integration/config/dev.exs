import Config

# For development, we disable any cache and enable
# debugging and code reloading.
config :phoenix_static_strapi_example, PhoenixStaticStrapiExampleWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "eCM9MJfvb+T6TXdK6sRxqBCQjkkm5TL6jbLp7a8KjTHG6XmKQcJrJjZKs4R8D7qe"

# Watch static and templates for browser reloading.
config :phoenix_static_strapi_example, PhoenixStaticStrapiExampleWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/phoenix_static_strapi_example_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Enable dev routes for dashboard and mailbox
config :phoenix_static_strapi_example, dev_routes: true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime