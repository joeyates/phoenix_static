defmodule StrapiExampleWeb.BlogHTML do
  @moduledoc """
  HTML view for blog pages generated from Strapi CMS.
  
  This module demonstrates how to use PhoenixStatic.View to automatically
  generate view functions for all pages defined in the PostsSource module.
  """
  
  use StrapiExampleWeb, :html
  use PhoenixStatic.View, source: StrapiExample.Strapi.PostsSource
end