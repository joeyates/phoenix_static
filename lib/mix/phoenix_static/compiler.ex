defmodule Mix.PhoenixStatic.Compiler do
  def run() do
    html_layout = Application.fetch_env!(:phoenix_static, :html_layout)
    web_module = Application.fetch_env!(:phoenix_static, :web_module)
    {method, function, arguments} = Application.fetch_env!(:phoenix_static, :page_source)
    pages = apply(method, function, arguments)
    build_controller(pages, web_module, html_layout)
    build_view(pages, web_module)
    :ok
  end

  defp build_controller(pages, web_module, html_layout) do
    quoted =
      quote(
        bind_quoted: [
          html_layout: html_layout,
          pages: Macro.escape(pages),
          web_module: web_module
        ]
      ) do
        defmodule :"#{web_module}.PhoenixStaticController" do
          use Phoenix.Controller,
            formats: [:html],
            layouts: [html: html_layout]

          Enum.map(pages, fn %{action: action, assigns: assigns} ->
            def unquote(:"#{action}")(conn, _params) do
              render(conn, "#{unquote(action)}.html", unquote(assigns))
            end
          end)
        end
      end

    compile_module(quoted)
  end

  defp build_view(pages, web_module) do
    quoted =
      quote(bind_quoted: [pages: Macro.escape(pages), web_module: web_module]) do
        defmodule :"#{web_module}.PhoenixStaticHTML" do
          import Phoenix.HTML, only: [raw: 1]

          Enum.map(pages, fn %{action: action, content: content} ->
            def unquote(:"#{action}")(_assigns) do
              raw(unquote(content))
            end
          end)
        end
      end

    compile_module(quoted)
  end

  defp compile_module(quoted) do
    Code.compiler_options(ignore_module_conflict: true)
    [{module_name, bytecode}] = Code.compile_quoted(quoted)
    Code.compiler_options(ignore_module_conflict: false)
    base = Mix.Project.compile_path()
    module_path = Path.join(base, "#{module_name}.beam")
    File.write!(module_path, bytecode, [:write])
  end
end
