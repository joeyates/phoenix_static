defmodule PhoenixStatic.Page do
  @moduledoc """
  This module defines the information structure used to build static pages.
  """

  defstruct [:id, :action, :slug, :locale, :content, assigns: []]
end
