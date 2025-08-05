# PhoenixStatic

![Version](https://img.shields.io/hexpm/v/phoenix_static)

Build static pages into a Phoenix application at compile time.

# About

This library is designed to be used in a Phoenix application to generate static pages at compile time.

It is useful in cases where you have content hosted elsewhere (e.g. a CMS) and want to generate static pages for performance reasons.

# Configuration

To use this library, you need to add it to your `mix.exs` file:

```elixir
defp deps do
  [
    {:phoenix_static, "~> (see the badge above)"}
  ]
end
```

Next, implement the `PhoenixStatic.Source` behaviour in a module.
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

Now, implement a pair of modules, a controller and an HTML view.
The modules names **must** have the same base, i.e. `MyPages`
and end in `...Controller` and `...HTML`, as is normal in Phoenix.

The controller handles the requests for the static pages, and hands off
to the HTML view which renders the content.

```elixir
defmodule MyAppWeb.MyPagesController do
  use MyAppWeb, :controller
  use PhoenixStatic.Controller
end
```

The view needs to know about the source module you created earlier, so you need to specify the `source` option.

```elixir
defmodule MyAppWeb.MyPagesHTML do
  use MyAppWeb, :html
  use PhoenixStatic.View, source: MyAppWeb.Static
end
```

Finally, connect the controller to the router:

```elixir
defmodule MyAppWeb.Router do
  ...
  use PhoenixStatic.Routes, controllers: [MyAppWeb.MyPagesController], pipelines: [:browser]
  ...
end
```

All the routes indicated by your `PhoenixStatic.Source` implementation will be
automatically generated.

Note that you need to use `:pipelines` to indicate the same pipelines you would with normal Phoenix routes.

You can add as many controllers (and views and sources) as you like.

# Further Information

All page content is currently held in memory during compilation, so it is not
suitable for large amounts of data.

The data is saved in the HTML view module, and is available via the
`__phoenix_static_pages__/0` function.
