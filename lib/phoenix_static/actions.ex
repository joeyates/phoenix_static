defmodule PhoenixStatic.Actions do
  @doc false
  defmacro __using__(_opts \\ %{}) do
    view_pages =
      :phoenix_static
      |> Application.fetch_env!(:controllers)
      |> Enum.map(fn controller ->
        Code.ensure_compiled!(controller)

        view = html_view(controller)
        Code.ensure_compiled!(view)

        {view, view.__phoenix_static_pages__()}
      end)
      |> Enum.into(%{})
      |> Macro.escape()

    quote bind_quoted: [view_pages: view_pages] do
      @behaviour PhoenixStatic.Actions
      alias PhoenixStatic.Actions

      Enum.flat_map(view_pages, fn {view, pages} ->
        Enum.map(pages, fn {action, _page} ->
          quote do
            def unquote(String.to_atom(action))(conn, _params) do
              render(conn, "#{unquote(action)}.html")
            end
          end
        end)
      end)

      def __mix_recompile__?() do
        Enum.any?(view_pages, fn {view, _pages} ->
          Actions.should_recompile?(view, __MODULE__)
        end)
      end
    end
  end

  @callback static_source() :: module()

  def should_recompile?(view, module) do
    case Code.ensure_compiled(view) do
      {:module, _module} ->
        PhoenixStatic.Dependencies.older_than_module?(module, view)

      {:error, _reason} ->
        true
    end
  end

  def html_view(controller) do
    view_base = Phoenix.Naming.unsuffix(controller, "Controller")
    :"#{view_base}HTML"
  end
end
