defmodule PhoenixStatic.Actions do
  @doc false
  defmacro __using__(_opts \\ %{}) do
    view = Application.fetch_env!(:phoenix_static, :view)
    Code.ensure_compiled!(view)

    pages = Macro.escape(view.__phoenix_static_pages__())

    quote bind_quoted: [pages: pages] do
      Enum.map(pages, fn %{action: action, assigns: assigns} ->
        assigns = Macro.escape(assigns)

        def unquote(String.to_atom(action))(conn, _params) do
          render(conn, "#{unquote(action)}.html", unquote(assigns))
        end
      end)

      def __mix_recompile__?() do
        view = Application.fetch_env!(:phoenix_static, :view)
        Code.ensure_compiled!(view)

        our_modified =
          Mix.Project.compile_path()
          |> Path.join("#{__MODULE__}.beam")
          |> Mix.Utils.last_modified()

        view_modified =
          Mix.Project.compile_path()
          |> Path.join("#{view}.beam")
          |> Mix.Utils.last_modified()

        our_modified < view_modified
      end
    end
  end
end
