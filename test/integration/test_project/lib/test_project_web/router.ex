defmodule TestProjectWeb.Router do
  use TestProjectWeb, :router

  require PhoenixStatic.Routes

  def __mix_recompile__?(), do: true

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

  scope "/" do
    pipe_through :browser

    PhoenixStatic.Routes.define()
  end
end
