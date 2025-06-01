defmodule PhoenixStatic.Source do
  @moduledoc """
  Defines a behaviour for modules that can be used as a source of static routes.
  """

  @doc """
  Returns the content, path and other information for all static pages.
  """
  @callback list_pages() :: {:ok, [PhoenixStatic.Page.t()]}

  @doc """
  Returns the last modified timestamp of the source.

  The return value is a UNIX timestamp.

  Note, the granularity of the timestamp comparisons is one second.

  This function is called by the HTML view to determine
  whether the source has changed since the last compilation of the module.
  If the source has changed, the view, along with the related controller and
  the project's router module, will be recompiled.

  This function should be as fast, reliable and lightweight as possible as it
  is called on each compilation. Above all, in development mode, it will
  be called on each request.
  """
  @callback last_modified() :: {:ok, integer}
end
