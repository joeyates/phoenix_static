defmodule TestProject.Routes do
  alias PhoenixStatic.Page

  def list_pages() do
    "routes.json"
    |> File.read!()
    |> Jason.decode!(keys: :atoms)
    |> Enum.map(&struct!(Page, &1))
  end
end
