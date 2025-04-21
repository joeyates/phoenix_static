defmodule PhoenixStatic.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_static,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:phoenix, ">= 0.0.0"}
    ]
  end
end
