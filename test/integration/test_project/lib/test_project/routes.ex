defmodule TestProject.Routes do
  alias PhoenixStatic.Page

  def last_modified() do
    "routes.json"
    |> File.stat!()
    |> Map.get(:mtime)
    |> NaiveDateTime.from_erl!()
    |> DateTime.from_naive!("Etc/UTC")
  end

  def list_pages() do
    "routes.json"
    |> File.read!()
    |> Jason.decode!(keys: :atoms)
    |> Enum.map(&struct!(Page, &1))
  end
end
