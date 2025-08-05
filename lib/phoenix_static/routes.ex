defmodule PhoenixStatic.Routes do
  alias Phoenix.Router

  @doc false
  defmacro __using__(opts \\ %{}) do
    pipelines = Keyword.get(opts, :pipelines, [])
    controllers = Keyword.fetch!(opts, :controllers)

    controller_view_pages =
      controllers
      |> Enum.map(fn quoted_controller ->
        controller = Macro.expand(quoted_controller, __CALLER__)
        Code.ensure_compiled!(controller)

        view = PhoenixStatic.Actions.view_for(controller)
        Code.ensure_compiled!(view)

        [controller, view, view.__phoenix_static_pages__()]
      end)
      |> Macro.escape()

    quote do
      scope "/" do
        Enum.map(unquote(pipelines), fn pipeline ->
          pipe_through pipeline
        end)

        Enum.flat_map(unquote(controller_view_pages), fn [controller, _view, pages] ->
          Enum.map(pages, fn {_action, page} ->
            Router.get(page.path, controller, String.to_atom(page.action), page.route_options)
          end)
        end)
      end

      def __mix_recompile__?() do
        controller_view_pages = unquote(controller_view_pages)

        Enum.any?(controller_view_pages, fn [_controller, view, _pages] ->
          PhoenixStatic.Dependencies.should_recompile?(__MODULE__, view)
        end)
      end
    end
  end
end
