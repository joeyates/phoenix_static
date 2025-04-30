defmodule TestProjectWeb.Router do
  use TestProjectWeb, :router
  use PhoenixStatic.Routes, pipelines: [:browser]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TestProjectWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", TestProjectWeb do
    pipe_through :browser

    get "/", PageController, :home
  end
end
