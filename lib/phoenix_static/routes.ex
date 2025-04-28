defmodule PhoenixStatic.Routes do
  alias Phoenix.Router

  @doc false
  defmacro __using__(opts \\ %{}) do
    pipelines = Keyword.get(opts, :pipelines, [])

    quote do
      require PhoenixStatic.Routes

      def __mix_recompile__?(), do: true

      scope "/" do
        Enum.map(unquote(pipelines), fn pipeline ->
          pipe_through pipeline
        end)

        PhoenixStatic.Routes.define()
      end
    end
  end

  defmacro define do
    {module, function, arguments} = Application.fetch_env!(:phoenix_static, :page_source)
    pages = Macro.escape(apply(module, function, arguments))

    quote do
      Enum.map(unquote(pages), fn page ->
        options =
          if page.metadata do
            [metadata: page.metadata]
          else
            []
          end

        Router.get(
          page.path,
          PhoenixStaticWeb.GeneratedController,
          String.to_atom(page.action),
          options
        )
      end)
    end
  end
end
