import Config

config :phoenix_static,
  source: TestProject.Routes,
  controller: TestProjectWeb.GeneratedRoutesController,
  view: TestProjectWeb.GeneratedRoutesHTML
