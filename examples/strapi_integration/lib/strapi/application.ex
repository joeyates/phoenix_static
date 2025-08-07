defmodule Strapi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      StrapiWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:strapi, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Strapi.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Strapi.Finch},
      # Start a worker by calling: Strapi.Worker.start_link(arg)
      # {Strapi.Worker, arg},
      # Start to serve requests, typically the last entry
      StrapiWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Strapi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    StrapiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end