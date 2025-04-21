defmodule PhoenixStatic.Routes do
  alias Phoenix.Router

  defmacro define do
    {method, function, arguments} = Application.fetch_env!(:phoenix_static, :page_source)
    pages = Macro.escape(apply(method, function, arguments))

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
