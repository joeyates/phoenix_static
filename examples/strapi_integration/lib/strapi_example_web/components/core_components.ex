defmodule StrapiExampleWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.
  
  At first glance, this module may seem daunting, but its goal is to provide
  core building blocks for your application, such as modals, tables, and
  forms. The components consist mostly of markup and are well-documented
  with doc strings and declarative assigns. You may customize and style
  them in any way you want, based on your application growth and needs.
  """
  use Phoenix.Component

  @doc """
  Renders a live title.
  """
  def live_title(assigns) do
    ~H"""
    <title><%= @title %></title>
    """
  end
end