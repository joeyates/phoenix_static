defmodule PhoenixStatic.Actions do
  @doc false
  defmacro __using__(_opts \\ %{}) do
    view = Application.fetch_env!(:phoenix_static, :view)
    Code.ensure_compiled!(view)

    pages = Macro.escape(view.__phoenix_static_pages__())

    quote bind_quoted: [pages: pages] do
      Enum.map(pages, fn {action, _page} ->
        def unquote(String.to_atom(action))(conn, _params) do
          render(conn, "#{unquote(action)}.html")
        end
      end)

      def __mix_recompile__?() do
        view = Application.fetch_env!(:phoenix_static, :view)
        Code.ensure_compiled!(view)

        PhoenixStatic.Dependencies.older_than_module?(__MODULE__, view)
      end
    end
  end
end
