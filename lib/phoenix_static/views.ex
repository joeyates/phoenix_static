defmodule PhoenixStatic.Views do
  @doc false
  defmacro __using__(opts) do
    quoted_source = Keyword.fetch!(opts, :source)
    source = Macro.expand(quoted_source, __CALLER__)
    pages = source |> pages_by_action() |> Macro.escape()

    quote bind_quoted: [pages: pages, source: source] do
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
        source = unquote(source)

        case Code.ensure_compiled(source) do
          {:module, _module} ->
            source_module_changed =
              PhoenixStatic.Dependencies.older_than_module?(__MODULE__, source)

            source_last_modified = PhoenixStatic.Views.content_last_modified(source)

            source_data_changed =
              PhoenixStatic.Dependencies.older_than_unix_timestamp?(
                __MODULE__,
                source_last_modified
              )

            source_module_changed or source_data_changed

          {:error, _reason} ->
            true
        end
      end
    end
  end

  def content_last_modified(source) do
    {:ok, content_last_modified} = apply(source, :last_modified, [])
    content_last_modified
  end

  defp pages_by_action(source) do
    {:ok, pages} = fetch_pages(source)
    by_action(pages)
  end

  defp fetch_pages(source) do
    {:ok, _pages} = apply(source, :list_pages, [])
  end

  defp by_action(pages) do
    Enum.reduce(
      pages,
      %{},
      fn page, acc ->
        if Map.has_key?(acc, page.action) do
          raise "Duplicate action found: #{page.action} in #{inspect(page.path)}"
        end

        Map.put(acc, page.action, page)
      end
    )
  end
end
