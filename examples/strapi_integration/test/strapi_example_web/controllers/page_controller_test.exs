defmodule StrapiExampleWeb.PageControllerTest do
  use StrapiExampleWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Phoenix Static + Strapi CMS Example"
  end
end