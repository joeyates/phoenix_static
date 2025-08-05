defmodule PhoenixStatic.Controller do
  @doc false
  defmacro __using__(_opts \\ %{}) do
    controller = __CALLER__.module
    Code.ensure_compiled!(controller)

    view = __MODULE__.view_for(controller)
    Code.ensure_compiled!(view)

    pages = Macro.escape(view.__phoenix_static_pages__())

    quote bind_quoted: [view: view, pages: pages] do
      Enum.map(pages, fn {action, _page} ->
        def unquote(String.to_atom(action))(conn, _params) do
          render(conn, "#{unquote(action)}.html")
        end
      end)

      def __mix_recompile__?() do
        view = PhoenixStatic.Controller.view_for(__MODULE__)
        PhoenixStatic.Dependencies.should_recompile?(__MODULE__, unquote(view))
      end
    end
  end

  def view_for(controller) do
    view_base = Phoenix.Naming.unsuffix(controller, "Controller")
    :"#{view_base}HTML"
  end
end
