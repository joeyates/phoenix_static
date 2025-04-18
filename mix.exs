defmodule PhoenixStatic.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_static,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod
    ]
  end

  def application do
    []
  end
end
