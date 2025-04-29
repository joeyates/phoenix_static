defmodule PhoenixStatic.Views do
  @doc false
  defmacro __using__(_opts \\ %{}) do
    {module, function, arguments} = Application.fetch_env!(:phoenix_static, :page_source)
    pages = apply(module, function, arguments)

    quote(bind_quoted: [pages: Macro.escape(pages)]) do
      def __mix_recompile__?() do
        {module, function, arguments} = Application.fetch_env!(:phoenix_static, :last_modified)
        source_last_modified = apply(module, function, arguments)

        ebin_path = Path.join(Mix.Project.compile_path(), "#{__MODULE__}.beam")
        modified = Mix.Utils.last_modified(ebin_path)

        case {modified, source_last_modified} do
          {0, _} ->
            true

          {_, nil} ->
            false

          {modified, source_last_modified} ->
            unix_time = DateTime.to_unix(source_last_modified, :second)

            modified < unix_time
        end
      end

      Enum.map(pages, fn %{action: action, content: content} ->
        def unquote(:"#{action}")(_assigns) do
          raw(unquote(content))
        end
      end)
    end
  end
end


