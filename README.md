# PhoenixStatic

Build static pages into a Phoenix application at compile time.

# About

This library is designed to be used in a Phoenix application to generate static pages at compile time.

It is useful in cases where you have content hosted elsewhere (e.g. a CMS) and want to generate static pages for performance reasons.

# Configuration

To use this library, you need to add it to your `mix.exs` file:

```elixir
defp deps do
  [
    {:phoenix_static, "~> 0.3.0"}
  ]
end
```

Then you need to implement the `PhoenixStatic.Source` behaviour in a module.
This module will be responsible for fetching the content and providing the last modification date.

```elixir
defmodule MyAppWeb.Static do
  @behaviour PhoenixStatic.Source

  @impl true
  def list_pages() do
    # Fetch content from your CMS or other source
    {:ok, content}
  end

  @impl true
  def last_modified() do
    # Return the last modification time of the content
    {:ok, last_modified_time}
  end
end
```

Now, inject the static pages into the router, a Controller and its HTML View:

```elixir
defmodule MyAppWeb.Router do
  ...
  use PhoenixStatic.Routes, pipelines: [:browser]
  ...
end

defmodule MyAppWeb.MyPageController do
  use MyAppWeb, :controller
  use PhoenixStatic.Actions

  ...
end

defmodule MyAppWeb.MyPageHTML do
  use MyAppWeb, :html
  use PhoenixStatic.Views

  ...
end
```

Then, you need to configure it in your `config/config.exs` file:

```elixir
config :phoenix_static,
  source: MyAppWeb.Static,
  controller: MyAppWeb.MyPageController,
  view: MyAppWeb.MyPageHTML
```

# Further Information

All page content is currently held in memory during compilation, so it is not
suitable for large amounts of data.

The data is saved in the HTML view module, and is available via the
`__phoenix_static_pages__/1` function.
