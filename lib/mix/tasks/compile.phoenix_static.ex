defmodule Mix.Tasks.Compile.PhoenixStatic do
  @moduledoc """
  Create static pages based on build-time content
  """

  use Mix.Task

  @shortdoc "Create static pages based on build-time content"
  def run(_args) do
    :ok = Mix.PhoenixStatic.Compiler.run()
  end
end
