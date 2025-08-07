defmodule StrapiWeb.BlogHTML do
  @moduledoc """
  HTML view for blog pages generated from Strapi CMS.
  
  This module demonstrates how to use PhoenixStatic.View to automatically
  generate view functions for all pages defined in the StrapiSource module.
  """
  
  use StrapiWeb, :html
  use PhoenixStatic.View, source: StrapiWeb.StrapiSource
end