defmodule StrapiWeb.PageController do
  use StrapiWeb, :controller

  def home(conn, _params) do
    # The home page is a good example of rendering plain HTML without any data.
    render(conn, :home, layout: false)
  end
end