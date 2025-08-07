defmodule StrapiExample.Strapi.PostsSourceTest do
  use ExUnit.Case
  alias StrapiExample.Strapi.PostsSource

  describe "last_modified/0" do
    test "returns a unix timestamp" do
      assert {:ok, timestamp} = PostsSource.last_modified()
      assert is_integer(timestamp)
      assert timestamp > 0
    end
  end

  describe "list_pages/0" do
    test "returns fallback pages when API is unavailable" do
      # With the default test configuration pointing to localhost:9999 (unavailable)
      assert {:ok, pages} = PostsSource.list_pages()
      assert is_list(pages)
      assert length(pages) >= 1
      
      # Should contain at least the blog index fallback page
      blog_page = Enum.find(pages, fn page -> page.action == "blog_index" end)
      assert blog_page != nil
      assert blog_page.path == "/blog"
      assert String.contains?(blog_page.content, "issues connecting to the CMS")
    end
  end
end