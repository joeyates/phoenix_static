defmodule StrapiExampleWeb.BlogHTML do
  @moduledoc """
  HTML view module for rendering static blog pages from Strapi CMS content.
  
  This module uses PhoenixStatic.View to automatically generate template
  functions for each page defined in the StrapiSource module.
  
  The view renders:
  - Blog index page
  - Individual blog post pages
  - Category pages
  
  All content is pre-rendered as HTML during compilation for optimal performance.
  """
  
  use StrapiExampleWeb, :html
  use PhoenixStatic.View, source: StrapiExampleWeb.StrapiSource
end