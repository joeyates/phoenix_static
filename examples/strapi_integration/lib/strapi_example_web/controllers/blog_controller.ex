defmodule StrapiExampleWeb.BlogController do
  @moduledoc """
  Controller for handling static blog pages generated from Strapi CMS content.
  
  This controller uses PhoenixStatic.Controller to automatically generate
  action functions for each page defined in the StrapiSource module.
  
  The controller handles:
  - Blog index page (/blog)
  - Individual blog post pages (/posts/{slug})
  - Category pages (/categories/{slug})
  """
  
  use StrapiExampleWeb, :controller
  use PhoenixStatic.Controller
end