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
    pages_by_action = Enum.group_by(pages, & &1.action)

    quoted =
      quote(
        bind_quoted: [
          html_layout: html_layout,
          pages: Macro.escape(pages),
          pages_by_action: Macro.escape(pages_by_action),
          web_module: web_module
        ]
      ) do
        defmodule :"#{web_module}.PhoenixStaticController" do
          use Phoenix.Controller,
            formats: [:html],
            layouts: [html: html_layout]

          pages_by_action
          |> Enum.flat_map(fn {action, _pages} ->
            action_def =
              def unquote(:"#{action}")(conn, _params) do
                locale = Gettext.get_locale()
                assigns = unquote(:"#{action}_assigns")(locale)

                render(conn, "#{unquote(action)}_#{locale}.html", assigns)
              end

            assigns_def =
              Enum.map(pages, fn page ->
                %{action: action, locale: locale, assigns: assigns} = page
                assigns = Macro.escape(assigns)

                defp unquote(:"#{action}_assigns")(unquote(locale)) do
                  unquote(assigns)
                end
              end)

            [action_def, assigns_def]
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

          Enum.map(pages, fn %{action: action, locale: locale, content: content} ->
            def unquote(:"#{action}_#{locale}")(_assigns) do
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
