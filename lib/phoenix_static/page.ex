defmodule PhoenixStatic.Page do
  @moduledoc """
  This module defines the information structure used to build static pages.
  """

  @enforce_keys [:action, :path, :content]
  defstruct [:action, :path, :content, :metadata, assigns: []]
end
