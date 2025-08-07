defmodule StrapiExampleWeb.Router do
  use StrapiExampleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {StrapiExampleWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Static routes generated from Strapi CMS content
  use PhoenixStatic.Routes, 
    controllers: [StrapiExampleWeb.BlogController], 
    pipelines: [:browser]

  scope "/", StrapiExampleWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", StrapiExampleWeb do
  #   pipe_through :api
  # end
end