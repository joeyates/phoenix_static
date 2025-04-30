defmodule PhoenixStatic.Page do
  @moduledoc """
  This module defines the information structure used to build static pages.
  """

  @enforce_keys [:action, :path, :content]
  defstruct [:action, :path, :content, :metadata, assigns: []]

  @type t() :: %__MODULE__{
          action: String.t(),
          path: String.t(),
          content: String.t(),
          metadata: map() | nil,
          assigns: list()
        }
end
