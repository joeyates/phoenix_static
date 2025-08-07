defmodule StrapiExample.MixProject do
  use Mix.Project

  def project do
    [
      app: :strapi_example,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {StrapiExample.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp deps do
    [
      {:phoenix, "~> 1.7.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0.0-rc.0"},
      {:plug_cowboy, "~> 2.5"},
      {:httpoison, "~> 2.0"},
      {:jason, "~> 1.2"},
      {:phoenix_static, path: "../.."}
    ]
  end
end