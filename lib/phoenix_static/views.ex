defmodule PhoenixStatic.Views do
  @doc false
  defmacro __using__(_opts \\ %{}) do
    pages = Macro.escape(pages_by_action())

    quote bind_quoted: [pages: pages] do
      Enum.map(pages, fn {action, _page} ->
        def unquote(String.to_atom(action))(_assigns) do
          __phoenix_static_pages__()
          |> get_in([unquote(action), Access.key!(:content)])
          |> Phoenix.HTML.raw()
        end
      end)

      def __phoenix_static_pages__() do
        unquote(Macro.escape(pages))
      end

      def __mix_recompile__?() do
        source = Application.fetch_env!(:phoenix_static, :source)
        {:ok, source_last_modified} = apply(source, :last_modified, [])

        our_modified =
          Mix.Project.compile_path()
          |> Path.join("#{__MODULE__}.beam")
          |> Mix.Utils.last_modified()

        case {our_modified, source_last_modified} do
          {0, _} ->
            true

          {_, nil} ->
            false

          {our_modified, source_last_modified} ->
            our_modified < source_last_modified
        end
      end
    end
  end

  defp pages_by_action() do
    {:ok, pages} = fetch_pages()
    by_action(pages)
  end

  defp fetch_pages() do
    source = Application.fetch_env!(:phoenix_static, :source)
    {:ok, _pages} = apply(source, :list_pages, [])
  end

  defp by_action(pages) do
    Enum.reduce(
      pages,
      %{},
      fn page, acc -> Map.put(acc, page.action, page) end
    )
  end
end
