defmodule PhoenixStatic.Dependencies do
  @moduledoc """
  Conveniences for working with dependencies.

  In this module, "older" means "needs recompiling when considering...".
  So, if we compare a first module to a module that doesn't exist,
  the first module doesn't need recompiling, so it's not "older".
  """

  def older_than_unix_timestamp?(_module, nil), do: false

  def older_than_unix_timestamp?(module, last_modified) do
    module_modified = last_modified(module)

    if module_modified == 0 do
      true
    else
      module_modified < last_modified
    end
  end

  def older_than_module?(module_1, module_2) do
    module_1_modified = last_modified(module_1)
    module_2_modified = last_modified(module_2)

    case {module_1_modified, module_2_modified} do
      {0, _} -> true
      {_, 0} -> false
      {m1, m2} -> m1 < m2
    end
  end

  def last_modified(module) do
    Mix.Project.compile_path()
    |> Path.join("#{module}.beam")
    |> Mix.Utils.last_modified()
  end
end
