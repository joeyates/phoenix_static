defmodule StrapiExampleWeb.Router do
  use StrapiExampleWeb, :router

  # Use PhoenixStatic.Routes to automatically generate routes from the PostsSource
  use PhoenixStatic.Routes,
    controllers: [StrapiExampleWeb.BlogController],
    pipelines: [:browser]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {StrapiExampleWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", StrapiExampleWeb do
    pipe_through :browser

    get "/", PageController, :home
  end
end