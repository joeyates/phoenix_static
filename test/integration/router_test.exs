defmodule PhoenixStatic.Integration.RouterTest do
  use ExUnit.Case, async: false

  import Plug.Test
  import Plug.Conn
  import Phoenix.ConnTest

  defmodule IntegrationSource do
    @behaviour PhoenixStatic.Source

    alias PhoenixStatic.Page

    @impl true
    def list_pages() do
      {:ok, [%Page{action: "about", path: "/about", content: "<div>About</div>"}]}
    end

    @impl true
    def last_modified() do
      {:ok, DateTime.utc_now() |> DateTime.to_unix() |> Kernel.-(1000)}
    end
  end

  Application.put_env(:phoenix_static, :source, IntegrationSource)

  defmodule IntegrationHTML do
    use PhoenixStatic.Views
  end

  Application.put_env(:phoenix_static, :view, IntegrationHTML)

  defmodule IntegrationController do
    use Phoenix.Controller,
      formats: [:html],
      layouts: [html: false]

    use PhoenixStatic.Actions
  end

  Application.put_env(:phoenix_static, :controller, IntegrationController)

  defmodule IntegrationRouter do
    use Phoenix.Router
    use PhoenixStatic.Routes, pipelines: [:browser]

    pipeline :browser do
      plug :accepts, ["html"]
      plug :put_layout, html: false
    end
  end

  test "it generates routes" do
    conn =
      :get
      |> conn("/about")
      |> IntegrationRouter.call([])

    assert html_response(conn, 200) =~ "About"
  end
end
