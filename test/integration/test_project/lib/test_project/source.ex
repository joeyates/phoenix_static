defmodule TestProject.Source do
  @behaviour PhoenixStatic.Source

  alias PhoenixStatic.Page

  @impl true
  def last_modified() do
    "routes.json"
    |> File.stat!()
    |> Map.get(:mtime)
    |> :calendar.datetime_to_gregorian_seconds()
    |> Kernel.-(62_167_219_200)
    |> then(&{:ok, &1})
  end

  @impl true
  def list_pages() do
    "routes.json"
    |> File.read!()
    |> Jason.decode!(keys: :atoms)
    |> Enum.map(&struct!(Page, &1))
    |> then(&{:ok, &1})
  end
end
