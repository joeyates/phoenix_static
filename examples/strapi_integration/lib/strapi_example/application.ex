defmodule StrapiExample.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {DNSCluster, query: Application.get_env(:strapi_example, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: StrapiExample.PubSub},
      # Start to serve requests, typically the last entry
      StrapiExampleWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StrapiExample.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    StrapiExampleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end