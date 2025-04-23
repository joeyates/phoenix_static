import Config

config :phoenix_static,
  html_layout: TestProjectWeb.Layouts,
  page_source: {TestProject.Routes, :list_pages, []}
