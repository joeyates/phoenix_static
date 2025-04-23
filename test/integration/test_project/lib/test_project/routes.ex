defmodule TestProject.Routes do
  alias PhoenixStatic.Page

  def list_pages() do
    [
      %Page{
        action: "about",
        path: "/about",
        content: "<div>About Us</div>"
      }
    ]
  end
end
