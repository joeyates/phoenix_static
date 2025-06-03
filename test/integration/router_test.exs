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
      page = %Page{
        action: "about",
        path: "/about",
        content: "<div>About</div>",
        route_options: [assigns: %{page_title: "Page title from assigns"}]
      }

      {:ok, [page]}
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

  defmodule IntegrationLayout do
    def app(%{conn: conn, inner_content: {:safe, inner_content}}) do
      rendered = """
      <html>
        <head>
          <title>#{conn.assigns.page_title}</title>
        </head>
        <body>
          #{inner_content}
        </body>
      </html>
      """

      {:safe, rendered}
    end
  end

  defmodule IntegrationController do
    use Phoenix.Controller,
      formats: [:html],
      layouts: [html: IntegrationLayout]

    use PhoenixStatic.Actions
  end

  Application.put_env(:phoenix_static, :controller, IntegrationController)

  defmodule IntegrationRouter do
    use Phoenix.Router
    use PhoenixStatic.Routes, pipelines: [:browser]

    pipeline :browser do
      plug :accepts, ["html"]
    end
  end

  test "it generates routes" do
    conn =
      :get
      |> conn("/about")
      |> IntegrationRouter.call([])

    assert html_response(conn, 200) =~ "About"
  end

  test "it accepts assigns in Page.route_options" do
    conn =
      :get
      |> conn("/about")
      |> IntegrationRouter.call([])

    assert html_response(conn, 200) =~ "<title>Page title from assigns</title>"
  end
end
