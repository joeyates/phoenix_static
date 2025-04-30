defmodule PhoenixStatic.Views do
  @doc false
  defmacro __using__(_opts \\ %{}) do
    {module, function, arguments} = Application.fetch_env!(:phoenix_static, :page_source)

    pages =
      module
      |> apply(function, arguments)
      |> Macro.escape()

    quote bind_quoted: [pages: pages], location: :keep do
      Enum.map(pages, fn %{action: action, content: content} ->
        def unquote(String.to_atom(action))(_assigns) do
          raw(unquote(content))
        end
      end)

      def __phoenix_static_pages__() do
        unquote(Macro.escape(pages))
      end

      def __mix_recompile__?() do
        {module, function, arguments} = Application.fetch_env!(:phoenix_static, :last_modified)
        source_last_modified = apply(module, function, arguments)

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
            unix_time = DateTime.to_unix(source_last_modified, :second)

            our_modified < unix_time
        end
      end
    end
  end
end
