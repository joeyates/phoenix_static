defmodule PhoenixStatic.Actions do
  @doc false
  defmacro __using__(_opts \\ %{}) do
    {module, function, arguments} = Application.fetch_env!(:phoenix_static, :page_source)
    pages = Macro.escape(apply(module, function, arguments))

    quote(bind_quoted: [pages: pages]) do
      def __mix_recompile__?() do
        {module, function, arguments} = Application.fetch_env!(:phoenix_static, :last_modified)
        cms_last_modified = apply(module, function, arguments)

        ebin_path = Path.join(Mix.Project.compile_path(), "#{__MODULE__}.beam")
        modified = Mix.Utils.last_modified(ebin_path)

        case {modified, cms_last_modified} do
          {0, _} ->
            true

          {_, nil} ->
            false

          {modified, last_modified} ->
            unix_time = DateTime.to_unix(last_modified, :second)

            modified < unix_time
        end
      end

      Enum.map(pages, fn %{action: action, content: content, assigns: assigns} ->
        assigns = Macro.escape(assigns)

        def unquote(:"#{action}")(conn, _params) do
          render(conn, "#{unquote(action)}.html", unquote(assigns))
        end
      end)
    end
  end
end

