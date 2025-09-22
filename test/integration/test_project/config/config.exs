import Config

phoenix_static_disabled = System.get_env("PHOENIX_STATIC_DISABLED") in ~w(true 1)

config :phoenix_static,
  disabled: phoenix_static_disabled
