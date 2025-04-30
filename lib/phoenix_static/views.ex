defmodule PhoenixStatic.Views do
  @doc false
  defmacro __using__(_opts \\ %{}) do
    source = Application.fetch_env!(:phoenix_static, :source)

    {:ok, pages} =
      source
      |> apply(:list_pages, [])
      |> Macro.escape()

    quote bind_quoted: [pages: pages] do
      Enum.map(pages, fn %{action: action, content: content} ->
        def unquote(String.to_atom(action))(_assigns) do
          raw(unquote(content))
        end
      end)

      def __phoenix_static_pages__() do
        unquote(Macro.escape(pages))
      end

      def __mix_recompile__?() do
        source = Application.fetch_env!(:phoenix_static, :source)
        {:ok, source_last_modified} = apply(source, :last_modified, [])

        our_modified =
          Mix.Project.compile_path()
          |> Path.join("#{__MODULE__}.beam")
          |> Mix.Utils.last_modified()

        case {our_modified, source_last_modified} do
          {0, _} ->
            true

          {_, nil} ->
            false

          {our_modified, source_last_modified} ->
            our_modified < source_last_modified
        end
      end
    end
  end
end
