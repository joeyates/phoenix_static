defmodule Mix.PhoenixStaticTest do
  use ExUnit.Case, async: false

  setup_all do
    root = File.cwd!()
    test_path = Path.join([root, "test", "integration", "test_project"])

    File.cd!(test_path, fn ->
      {_clean_output, 0} = System.cmd("git", ["clean", "-ffdx"])
      {_deps_output, 0} = System.cmd("mix", ["deps.get"], stderr_to_stdout: true)
    end)

    on_exit(fn ->
      File.cd!(test_path, fn ->
        {_clean_output, 0} = System.cmd("git", ["clean", "-ffdx"])
      end)
    end)

    %{test_path: test_path}
  end

  test "it adds static routes", %{test_path: test_path} do
    Mix.Project.in_project(:test_project, test_path, fn _module ->
      write_routes([%{action: :about, path: "/about", content: "<div>About</div>"}])
      {_compile_output, 0} = System.cmd("mix", ["compile"], stderr_to_stdout: true)
      {output, 0} = System.cmd("mix", ["phx.routes"], stderr_to_stdout: true)
      assert output =~ ~r(GET\s+/about\s+PhoenixStaticWeb.GeneratedController\s+:about)
    end)
  end

  test "it updates static routes on each compilation", %{test_path: test_path} do
    Mix.Project.in_project(:test_project, test_path, fn _module ->
      write_routes([%{action: :about, path: "/about", content: "<div>About</div>"}])
      {_compile_output, 0} = System.cmd("mix", ["compile"], stderr_to_stdout: true)
      {output_1, 0} = System.cmd("mix", ["phx.routes"], stderr_to_stdout: true)
      write_routes([%{action: :contact, path: "/contact", content: "<div>Contact</div>"}])
      {_compile_output, 0} = System.cmd("mix", ["compile"], stderr_to_stdout: true)
      {output_2, 0} = System.cmd("mix", ["phx.routes"], stderr_to_stdout: true)
      assert output_1 =~ ~r(GET\s+/about\s+PhoenixStaticWeb.GeneratedController\s+:about)
      assert output_2 =~ ~r(GET\s+/contact\s+PhoenixStaticWeb.GeneratedController\s+:contact)
    end)
  end

  defp write_routes(routes) do
    routes_content = Jason.encode!(routes)
    File.write!("routes.json", routes_content)
  end
end
