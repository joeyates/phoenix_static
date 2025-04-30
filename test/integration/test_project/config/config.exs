import Config

config :phoenix_static,
  last_modified: {TestProject.Routes, :last_modified, []},
  page_source: {TestProject.Routes, :list_pages, []},
  controller: TestProjectWeb.GeneratedRoutesController,
  view: TestProjectWeb.GeneratedRoutesHTML
