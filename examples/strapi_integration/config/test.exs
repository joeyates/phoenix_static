import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :strapi, StrapiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "eCM9MJfvb+T6TXdK6sRxqBCQjkkm5TL6jbLp7a8KjTHG6XmKQcJrJjZKs4R8D7qe",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Use a mock Strapi URL for tests
config :strapi,
  strapi_url: "http://localhost:9999"

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime