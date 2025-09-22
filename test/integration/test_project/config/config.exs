import Config

IO.puts("Loading config.exs")
phoenix_static_disabled = System.get_env("PHOENIX_STATIC_DISABLED") in ~w(true 1)
IO.puts("phoenix_static_disabled: #{phoenix_static_disabled}")

config :phoenix_static,
  disabled: phoenix_static_disabled
