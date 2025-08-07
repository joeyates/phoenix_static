defmodule StrapiExample.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      StrapiExampleWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: StrapiExample.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    StrapiExampleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end