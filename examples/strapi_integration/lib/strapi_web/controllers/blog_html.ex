defmodule PhoenixStaticStrapiExampleWeb.BlogHTML do
  @moduledoc """
  HTML view for blog pages generated from Strapi CMS.
  
  This module demonstrates how to use PhoenixStatic.View to automatically
  generate view functions for all pages defined in the StrapiSource module.
  """
  
  use PhoenixStaticStrapiExampleWeb, :html
  use PhoenixStatic.View, source: PhoenixStaticStrapiExampleWeb.StrapiSource
end