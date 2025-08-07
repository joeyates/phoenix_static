defmodule StrapiWeb.BlogController do
  @moduledoc """
  Controller for handling blog-related static pages generated from Strapi CMS.
  
  This controller demonstrates how to use PhoenixStatic.Controller to automatically
  generate controller actions for all pages defined in the StrapiSource module.
  """
  
  use StrapiWeb, :controller
  use PhoenixStatic.Controller
end