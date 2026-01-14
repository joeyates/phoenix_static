defmodule PhoenixStatic do
  @moduledoc false

  @disabled Application.compile_env(:phoenix_static, :disabled, false)

  def disabled?(), do: @disabled
end
