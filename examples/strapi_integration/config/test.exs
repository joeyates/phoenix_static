import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :strapi_example, StrapiExampleWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "example_test_secret_key_base",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Strapi test configuration - use a mock or test instance
config :strapi_example,
  strapi_api_url: System.get_env("STRAPI_API_URL") || "http://localhost:1337"