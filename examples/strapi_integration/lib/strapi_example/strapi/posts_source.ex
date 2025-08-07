defmodule StrapiExample.Strapi.PostsSource do
  @moduledoc """
  A PhoenixStatic source module that fetches posts and categories from Strapi CMS.
  
  This module demonstrates how to:
  - Fetch Posts and Categories from Strapi REST API
  - Handle relationships between content types
  - Generate static pages for different content types
  - Implement proper error handling and caching
  """

  @behaviour PhoenixStatic.Source

  alias PhoenixStatic.Page
  require Logger

  @impl true
  def list_pages() do
    with {:ok, posts} <- fetch_posts(),
         {:ok, categories} <- fetch_categories() do
      pages = 
        generate_post_pages(posts) ++
        generate_category_pages(categories, posts) ++
        [generate_blog_index_page(posts, categories)]

      {:ok, pages}
    else
      error ->
        Logger.error("Failed to fetch Strapi content: #{inspect(error)}")
        # Return fallback pages in case of API failure
        {:ok, generate_fallback_pages()}
    end
  end

  @impl true
  def last_modified() do
    case fetch_last_modified() do
      {:ok, timestamp} -> {:ok, timestamp}
      {:error, _reason} -> 
        # Return current timestamp if we can't determine last modified
        {:ok, :os.system_time(:second)}
    end
  end

  # Private functions

  defp fetch_posts() do
    url = "#{strapi_url()}/api/posts?populate=categories"
    
    case Req.get(url, headers: headers()) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        case body do
          %{"data" => posts} -> {:ok, posts}
          _ -> {:error, "Invalid response format"}
        end
      {:ok, %Req.Response{status: status_code}} ->
        {:error, "HTTP #{status_code}"}
      {:error, _} = error ->
        error
    end
  end

  defp fetch_categories() do
    url = "#{strapi_url()}/api/categories"
    
    case Req.get(url, headers: headers()) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        case body do
          %{"data" => categories} -> {:ok, categories}
          _ -> {:error, "Invalid response format"}
        end
      {:ok, %Req.Response{status: status_code}} ->
        {:error, "HTTP #{status_code}"}
      {:error, _} = error ->
        error
    end
  end

  defp fetch_last_modified() do
    # Try to get the latest post's updated timestamp (UNIX timestamp)
    url = "#{strapi_url()}/api/posts?sort=updatedAt:desc&pagination[limit]=1"
    
    case Req.get(url, headers: headers()) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        case body do
          %{"data" => [%{"attributes" => %{"updatedAt" => updated_at}} | _]} ->
            case DateTime.from_iso8601(updated_at) do
              {:ok, datetime, _} -> {:ok, DateTime.to_unix(datetime)}
              {:error, _} -> {:error, "Invalid timestamp"}
            end
          %{"data" => []} ->
            {:ok, :os.system_time(:second)}
          _ ->
            {:error, "Invalid response format"}
        end
      {:error, _} = error ->
        error
    end
  end

  defp generate_post_pages(posts) do
    Enum.map(posts, fn post ->
      %{"id" => id, "attributes" => attributes} = post
      %{"title" => title, "content" => content, "slug" => slug} = attributes
      
      category_names = case get_in(post, ["attributes", "categories", "data"]) do
        nil -> []
        [] -> []
        categories -> Enum.map(categories, fn cat -> get_in(cat, ["attributes", "name"]) end)
      end

      category_text = if Enum.empty?(category_names) do
        "Uncategorized"
      else
        Enum.join(category_names, ", ")
      end

      html_content = """
      <article class="post">
        <header>
          <h1>#{Phoenix.HTML.html_escape(title)}</h1>
          <p class="category">Categories: #{Phoenix.HTML.html_escape(category_text)}</p>
        </header>
        <div class="content">
          #{content}
        </div>
        <footer>
          <a href="/blog">← Back to Blog</a>
        </footer>
      </article>
      """

      %Page{
        action: "post_#{id}",
        path: "/posts/#{slug}",
        content: html_content
      }
    end)
  end

  defp generate_category_pages(categories, posts) do
    Enum.map(categories, fn category ->
      %{"id" => category_id, "attributes" => attributes} = category
      %{"name" => name, "slug" => slug, "description" => description} = attributes

      # Filter posts for this category
      category_posts = Enum.filter(posts, fn post ->
        case get_in(post, ["attributes", "categories", "data"]) do
          nil -> false
          [] -> false
          categories -> Enum.any?(categories, fn cat -> get_in(cat, ["id"]) == category_id end)
        end
      end)

      posts_html = if Enum.empty?(category_posts) do
        "<p>No posts in this category yet.</p>"
      else
        category_posts
        |> Enum.map(fn post ->
          %{"attributes" => %{"title" => title, "slug" => post_slug}} = post
          "<li><a href=\"/posts/#{post_slug}\">#{Phoenix.HTML.html_escape(title)}</a></li>"
        end)
        |> Enum.join("\n")
        |> then(&"<ul>#{&1}</ul>")
      end

      html_content = """
      <div class="category-page">
        <header>
          <h1>#{Phoenix.HTML.html_escape(name)}</h1>
          <p class="description">#{Phoenix.HTML.html_escape(description || "")}</p>
        </header>
        <section class="posts">
          <h2>Posts in this category</h2>
          #{posts_html}
        </section>
        <footer>
          <a href="/blog">← Back to Blog</a>
        </footer>
      </div>
      """

      %Page{
        action: "category_#{category_id}",
        path: "/categories/#{slug}",
        content: html_content
      }
    end)
  end

  defp generate_blog_index_page(posts, categories) do
    recent_posts = posts
                   |> Enum.take(10)
                   |> Enum.map(fn post ->
                     %{"attributes" => %{"title" => title, "slug" => slug}} = post
                     category_names = case get_in(post, ["attributes", "categories", "data"]) do
                       nil -> []
                       [] -> []
                       categories -> Enum.map(categories, fn cat -> get_in(cat, ["attributes", "name"]) end)
                     end
                     category_text = if Enum.empty?(category_names) do
                       "Uncategorized"
                     else
                       Enum.join(category_names, ", ")
                     end
                     "<li><a href=\"/posts/#{slug}\">#{Phoenix.HTML.html_escape(title)}</a> <span class=\"category\">(#{Phoenix.HTML.html_escape(category_text)})</span></li>"
                   end)
                   |> Enum.join("\n")

    categories_html = categories
                      |> Enum.map(fn category ->
                        %{"attributes" => %{"name" => name, "slug" => slug}} = category
                        "<li><a href=\"/categories/#{slug}\">#{Phoenix.HTML.html_escape(name)}</a></li>"
                      end)
                      |> Enum.join("\n")

    html_content = """
    <div class="blog-index">
      <header>
        <h1>Blog</h1>
        <p>Welcome to our blog powered by Strapi CMS and Phoenix Static!</p>
      </header>
      
      <section class="recent-posts">
        <h2>Recent Posts</h2>
        #{if String.trim(recent_posts) == "", do: "<p>No posts available.</p>", else: "<ul>#{recent_posts}</ul>"}
      </section>
      
      <section class="categories">
        <h2>Categories</h2>
        #{if String.trim(categories_html) == "", do: "<p>No categories available.</p>", else: "<ul>#{categories_html}</ul>"}
      </section>
    </div>
    """

    %Page{
      action: "blog_index",
      path: "/blog",
      content: html_content
    }
  end

  defp generate_fallback_pages() do
    [
      %Page{
        action: "blog_index",
        path: "/blog",
        content: """
        <div class="blog-index">
          <header>
            <h1>Blog</h1>
            <p>Welcome to our blog! Currently experiencing issues connecting to the CMS.</p>
          </header>
          <section>
            <p>Please check back later or contact the administrator if this problem persists.</p>
          </section>
        </div>
        """
      }
    ]
  end

  defp strapi_url() do
    Application.get_env(:strapi_example, :strapi_url)
  end

  defp headers() do
    base_headers = [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"}
    ]
    
    case strapi_api_key() do
      nil -> base_headers
      key -> [{"Authorization", "Bearer #{key}"} | base_headers]
    end
  end
  
  defp strapi_api_key() do
    Application.get_env(:strapi_example, :strapi_api_key)
  end
end