defmodule PhoenixStatic.Routes do
  alias Phoenix.Router

  @doc false
  defmacro __using__(opts \\ %{}) do
    pipelines = Keyword.get(opts, :pipelines, [])

    controller_view_pages =
      :phoenix_static
      |> Application.fetch_env!(:controllers)
      |> Enum.map(fn controller ->
        Code.ensure_compiled!(controller)
        view = PhoenixStatic.Actions.html_view(controller)
        Code.ensure_compiled!(view)

        {controller, view, view.__phoenix_static_pages__()}
      end)
      |> Macro.escape()

    quote bind_quoted: [controller_view_pages: controller_view_pages, pipelines: pipelines] do
      scope "/" do
        pipe_throughs =
          Enum.map(pipelines, fn pipeline ->
            pipe_through pipeline
          end)

        routes =
          Enum.flat_map(controller_view_pages, fn {controller, _view, pages} ->
            Enum.map(pages, fn {_action, page} ->
              Router.get(page.path, controller, String.to_atom(page.action), page.route_options)
            end)
          end)

        pipe_throughs ++ routes
      end

      def __mix_recompile__?() do
        Enum.any?(view_pages, fn {view, _pages} ->
          PhoenixStatic.Actions.should_recompile?(view, __MODULE__)
        end)
      end
    end
  end
end
