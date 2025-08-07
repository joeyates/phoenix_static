# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :phoenix_static_strapi_example, PhoenixStaticStrapiExampleWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: PhoenixStaticStrapiExampleWeb.ErrorHTML, json: PhoenixStaticStrapiExampleWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: PhoenixStaticStrapiExample.PubSub,
  live_view: [signing_salt: "j6Gh6Bpz"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Strapi configuration
config :phoenix_static_strapi_example,
  strapi_url: System.get_env("STRAPI_URL", "http://localhost:1337")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"