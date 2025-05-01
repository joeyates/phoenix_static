defmodule PhoenixStatic.Dependencies do
  @moduledoc """
  Conveniences for working with dependencies.
  """

  def older_than_unix_timestamp?(_module, nil), do: false

  def older_than_unix_timestamp?(module, last_modified) do
    module_modified =
      Mix.Project.compile_path()
      |> Path.join("#{module}.beam")
      |> Mix.Utils.last_modified()

    if module_modified == 0 do
      true
    else
      module_modified < last_modified
    end
  end
end
