defmodule PhoenixStatic.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_static,
      version: "0.1.0",
      elixir: "~> 1.17",
      deps: deps(),
      description: "Build static pages into a Phoenix application at compile time",
      elixirc_paths: ["lib"],
      package: package(),
      start_permanent: Mix.env() == :prod
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:jason, ">= 0.0.0", only: :test},
      {:phoenix, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1", only: :test},
      {:phoenix_live_view, "~> 1.0.0-rc.1", only: :test}
    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/joeyates/phoenix_static"
      },
      maintainers: ["Joe Yates"]
    }
  end
end
