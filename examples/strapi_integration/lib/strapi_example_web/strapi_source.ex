defmodule StrapiExampleWeb.StrapiSource do
  @moduledoc """
  PhoenixStatic source module for fetching content from Strapi CMS.
  
  This module implements the PhoenixStatic.Source behaviour to fetch
  blog posts and categories from a Strapi CMS API and generate static pages.
  
  ## Content Types
  
  - **Posts**: Blog posts with title, content, slug, publication date, and category relationship
  - **Categories**: Post categories with name, slug, and description
  
  ## Generated Pages
  
  - Individual blog posts at `/posts/{slug}`
  - Category pages at `/categories/{slug}`
  - Blog index page at `/blog`
  
  ## Configuration
  
  The Strapi API URL is configured via the `STRAPI_API_URL` environment variable
  or the application configuration under `:strapi_example, :strapi_api_url`.
  """
  
  @behaviour PhoenixStatic.Source
  
  require Logger
  
  alias PhoenixStatic.Page
  
  @impl true
  def list_pages() do
    with {:ok, categories} <- fetch_categories(),
         {:ok, posts} <- fetch_posts() do
      pages = 
        build_blog_index() ++
        build_category_pages(categories) ++
        build_post_pages(posts, categories)
      
      {:ok, pages}
    else
      {:error, reason} ->
        Logger.error("Failed to fetch content from Strapi: #{inspect(reason)}")
        # Return empty list to allow compilation to continue
        {:ok, []}
    end
  end
  
  @impl true
  def last_modified() do
    # For this example, we check the last modified time of both posts and categories
    # In a real implementation, you might want to cache this or use Strapi's updatedAt fields
    with {:ok, posts_modified} <- get_posts_last_modified(),
         {:ok, categories_modified} <- get_categories_last_modified() do
      {:ok, max(posts_modified, categories_modified)}
    else
      {:error, _reason} ->
        # Return current timestamp if we can't determine last modified time
        {:ok, :os.system_time(:second)}
    end
  end
  
  # Private functions
  
  defp strapi_api_url do
    Application.get_env(:strapi_example, :strapi_api_url) ||
      System.get_env("STRAPI_API_URL") ||
      "http://localhost:1337"
  end
  
  defp fetch_categories do
    url = "#{strapi_api_url()}/api/categories?populate=*"
    
    case HTTPoison.get(url, [], timeout: 10_000, recv_timeout: 10_000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"data" => categories}} ->
            {:ok, categories}
          {:error, reason} ->
            {:error, "Failed to parse categories JSON: #{inspect(reason)}"}
        end
      
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Strapi API returned status #{status_code} for categories"}
      
      {:error, reason} ->
        {:error, "HTTP request failed for categories: #{inspect(reason)}"}
    end
  end
  
  defp fetch_posts do
    url = "#{strapi_api_url()}/api/posts?populate=*"
    
    case HTTPoison.get(url, [], timeout: 10_000, recv_timeout: 10_000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"data" => posts}} ->
            {:ok, posts}
          {:error, reason} ->
            {:error, "Failed to parse posts JSON: #{inspect(reason)}"}
        end
      
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Strapi API returned status #{status_code} for posts"}
      
      {:error, reason} ->
        {:error, "HTTP request failed for posts: #{inspect(reason)}"}
    end
  end
  
  defp get_posts_last_modified do
    case fetch_posts() do
      {:ok, posts} ->
        last_modified = 
          posts
          |> Enum.map(fn post -> 
            get_in(post, ["attributes", "updatedAt"])
            |> parse_strapi_datetime()
          end)
          |> Enum.max(fn -> 0 end)
        
        {:ok, last_modified}
      
      {:error, reason} ->
        {:error, reason}
    end
  end
  
  defp get_categories_last_modified do
    case fetch_categories() do
      {:ok, categories} ->
        last_modified = 
          categories
          |> Enum.map(fn category -> 
            get_in(category, ["attributes", "updatedAt"])
            |> parse_strapi_datetime()
          end)
          |> Enum.max(fn -> 0 end)
        
        {:ok, last_modified}
      
      {:error, reason} ->
        {:error, reason}
    end
  end
  
  defp parse_strapi_datetime(nil), do: 0
  defp parse_strapi_datetime(datetime_string) do
    case DateTime.from_iso8601(datetime_string) do
      {:ok, datetime, _} -> DateTime.to_unix(datetime)
      {:error, _} -> 0
    end
  end
  
  defp build_blog_index do
    content = """
    <!DOCTYPE html>
    <html>
    <head>
      <title>Blog - Strapi Example</title>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <style>
        body { font-family: system-ui, sans-serif; line-height: 1.6; max-width: 800px; margin: 0 auto; padding: 2rem; }
        .post-card { border: 1px solid #e2e8f0; border-radius: 8px; padding: 1.5rem; margin-bottom: 1.5rem; }
        .post-title { margin: 0 0 0.5rem 0; }
        .post-meta { color: #64748b; font-size: 0.875rem; margin-bottom: 1rem; }
        .post-excerpt { color: #374151; }
        a { color: #3b82f6; text-decoration: none; }
        a:hover { text-decoration: underline; }
        .category-tag { background: #e2e8f0; padding: 0.25rem 0.5rem; border-radius: 4px; font-size: 0.75rem; }
      </style>
    </head>
    <body>
      <h1>Blog</h1>
      <p>Welcome to our blog powered by Strapi CMS and PhoenixStatic!</p>
      <div id="posts-container">
        <!-- Posts will be loaded dynamically or you could pre-render them here -->
        <p>Loading posts...</p>
      </div>
    </body>
    </html>
    """
    
    [%Page{
      action: "blog_index",
      path: "/blog",
      content: content
    }]
  end
  
  defp build_category_pages(categories) do
    Enum.map(categories, fn category ->
      attributes = category["attributes"]
      slug = attributes["slug"]
      name = attributes["name"]
      description = attributes["description"] || ""
      
      content = """
      <!DOCTYPE html>
      <html>
      <head>
        <title>#{name} - Category - Strapi Example</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          body { font-family: system-ui, sans-serif; line-height: 1.6; max-width: 800px; margin: 0 auto; padding: 2rem; }
          .category-header { margin-bottom: 2rem; padding-bottom: 1rem; border-bottom: 2px solid #e2e8f0; }
          .category-description { color: #64748b; font-size: 1.125rem; }
          .post-card { border: 1px solid #e2e8f0; border-radius: 8px; padding: 1.5rem; margin-bottom: 1.5rem; }
          a { color: #3b82f6; text-decoration: none; }
          a:hover { text-decoration: underline; }
        </style>
      </head>
      <body>
        <div class="category-header">
          <h1>#{name}</h1>
          #{if description != "", do: "<p class=\"category-description\">#{description}</p>", else: ""}
        </div>
        
        <div id="posts-container">
          <p>Posts in this category will be displayed here.</p>
          <p><a href="/blog">← Back to all posts</a></p>
        </div>
      </body>
      </html>
      """
      
      %Page{
        action: "category_#{slug}",
        path: "/categories/#{slug}",
        content: content
      }
    end)
  end
  
  defp build_post_pages(posts, categories) do
    categories_by_id = 
      categories
      |> Enum.map(fn cat -> {cat["id"], cat} end)
      |> Map.new()
    
    Enum.map(posts, fn post ->
      attributes = post["attributes"]
      slug = attributes["slug"]
      title = attributes["title"]
      content_text = attributes["content"] || ""
      published_at = attributes["publishedAt"]
      
      # Get category information if available
      category = 
        case get_in(attributes, ["category", "data"]) do
          %{"id" => category_id} -> categories_by_id[category_id]
          _ -> nil
        end
      
      category_link = 
        case category do
          %{"attributes" => %{"name" => cat_name, "slug" => cat_slug}} ->
            "<a href=\"/categories/#{cat_slug}\" class=\"category-tag\">#{cat_name}</a>"
          _ -> ""
        end
      
      formatted_date = 
        case published_at do
          nil -> ""
          date_string ->
            case Date.from_iso8601(String.slice(date_string, 0, 10)) do
              {:ok, date} -> Date.to_string(date)
              {:error, _} -> ""
            end
        end
      
      content = """
      <!DOCTYPE html>
      <html>
      <head>
        <title>#{title} - Strapi Example</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          body { font-family: system-ui, sans-serif; line-height: 1.6; max-width: 800px; margin: 0 auto; padding: 2rem; }
          .post-header { margin-bottom: 2rem; padding-bottom: 1rem; border-bottom: 2px solid #e2e8f0; }
          .post-meta { color: #64748b; font-size: 0.875rem; margin-bottom: 1rem; }
          .post-content { margin-bottom: 2rem; }
          .category-tag { background: #e2e8f0; padding: 0.25rem 0.5rem; border-radius: 4px; font-size: 0.75rem; text-decoration: none; }
          .navigation { padding-top: 2rem; border-top: 1px solid #e2e8f0; }
          a { color: #3b82f6; text-decoration: none; }
          a:hover { text-decoration: underline; }
          h1 { margin: 0 0 1rem 0; }
        </style>
      </head>
      <body>
        <div class="post-header">
          <h1>#{title}</h1>
          <div class="post-meta">
            #{if formatted_date != "", do: "<span>Published on #{formatted_date}</span>", else: ""}
            #{if category_link != "", do: "<span> • #{category_link}</span>", else: ""}
          </div>
        </div>
        
        <div class="post-content">
          #{content_text}
        </div>
        
        <div class="navigation">
          <a href="/blog">← Back to all posts</a>
        </div>
      </body>
      </html>
      """
      
      %Page{
        action: "post_#{slug}",
        path: "/posts/#{slug}",
        content: content
      }
    end)
  end
end