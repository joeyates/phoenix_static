defmodule StrapiExampleWeb.PageController do
  use StrapiExampleWeb, :controller

  def home(conn, _params) do
    # The home page is just using regular Phoenix functionality
    render(conn, :home, layout: false)
  end
end