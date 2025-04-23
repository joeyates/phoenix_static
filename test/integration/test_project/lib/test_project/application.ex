defmodule TestProject.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [TestProjectWeb.Endpoint]

    opts = [strategy: :one_for_one, name: TestProject.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TestProjectWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
