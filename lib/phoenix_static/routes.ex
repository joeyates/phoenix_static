defmodule PhoenixStatic.Routes do
  alias Phoenix.Router

  @doc false
  defmacro __using__(opts \\ %{}) do
    pipelines = Keyword.get(opts, :pipelines, [])

    controller = Application.fetch_env!(:phoenix_static, :controller)
    Code.ensure_compiled!(controller)
    view = Application.fetch_env!(:phoenix_static, :view)
    Code.ensure_compiled!(view)

    pages = Macro.escape(view.__phoenix_static_pages__())

    quote bind_quoted: [pages: pages, controller: controller, pipelines: pipelines] do
      scope "/" do
        Enum.map(pipelines, fn pipeline ->
          pipe_through pipeline
        end)

        Enum.map(pages, fn {_action, page} ->
          options =
            if page.metadata do
              [metadata: page.metadata]
            else
              []
            end

          Router.get(page.path, controller, String.to_atom(page.action), options)
        end)
      end

      def __mix_recompile__?() do
        view = Application.fetch_env!(:phoenix_static, :view)
        Code.ensure_compiled!(view)

        PhoenixStatic.Dependencies.older_than_module?(__MODULE__, view)
      end
    end
  end
end
