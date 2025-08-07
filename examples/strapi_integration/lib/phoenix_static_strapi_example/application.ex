defmodule PhoenixStaticStrapiExample.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhoenixStaticStrapiExampleWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:phoenix_static_strapi_example, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PhoenixStaticStrapiExample.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PhoenixStaticStrapiExample.Finch},
      # Start a worker by calling: PhoenixStaticStrapiExample.Worker.start_link(arg)
      # {PhoenixStaticStrapiExample.Worker, arg},
      # Start to serve requests, typically the last entry
      PhoenixStaticStrapiExampleWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhoenixStaticStrapiExample.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhoenixStaticStrapiExampleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end