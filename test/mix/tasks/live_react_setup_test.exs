defmodule Mix.Tasks.LiveReact.SetupTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  import ExUnit.CaptureLog
  alias Mix.Tasks.LiveReact.Setup

  @tag :tmp_dir
  setup %{tmp_dir: tmp_dir} do
    File.rm_rf!(tmp_dir)
    File.mkdir_p!(tmp_dir)
    File.mkdir_p!("#{tmp_dir}/assets/js")
    File.mkdir_p!("#{tmp_dir}/lib/my_app_web/live")
    File.mkdir_p!("#{tmp_dir}/config")
    File.write!("#{tmp_dir}/assets/package.json", ~s({"dependencies":{}}))
    File.write!("#{tmp_dir}/assets/js/app.js", "// Existing app.js content")
    File.write!("#{tmp_dir}/config/config.exs", "use Mix.Config\n")
    File.write!("#{tmp_dir}/config/dev.exs", "use Mix.Config\n")

    Mix.Project.push(MixProject)
    :ok
  end

  test "run/1 creates all necessary files and updates existing ones", %{tmp_dir: tmp_dir} do
    log =
      capture_log(fn ->
        output =
          capture_io(fn ->
            File.cd!(tmp_dir, fn ->
              Setup.run([])
            end)
          end)

        # Check if files are created
        assert File.exists?("#{tmp_dir}/assets/react/HelloWorld.jsx")
        assert File.exists?("#{tmp_dir}/assets/react/index.js")
        assert File.exists?("#{tmp_dir}/lib/my_app_web/live/live_react_live.ex")

        # Check if existing files are updated
        assert File.read!("#{tmp_dir}/assets/js/app.js") =~
                 "import LiveReact from \"../vendor/live_react\""

        assert File.read!("#{tmp_dir}/config/config.exs") =~ "LiveReact configuration"
        assert File.read!("#{tmp_dir}/config/dev.exs") =~ "config :my_app, MyAppWeb.Endpoint"

        # Check package.json updates
        package_json = File.read!("#{tmp_dir}/assets/package.json") |> Jason.decode!()
        assert package_json["dependencies"]["react"]
        assert package_json["dependencies"]["react-dom"]
        assert package_json["dependencies"]["live_react"]

        # Check if the output contains the expected instructions
        assert output =~ "LiveReact has been successfully set up in your project!"
        assert output =~ "Install the required npm packages:"
        assert output =~ "$ cd assets && npm install && cd .."
        assert output =~ "Add the LiveReact route to your router.ex:"
        assert output =~ "live \"/live_react_example\", LiveReactLive"
        assert output =~ "Start your Phoenix server:"
        assert output =~ "$ mix phx.server"
        assert output =~ "Visit http://localhost:4000/live_react_example"
        refute output =~ "Run `mix deps.get`"
      end)

    # Check for the expected warning log
    assert log =~ "LiveReact package not found. This is expected in test environment."
  end
end

defmodule MixProject do
  def project do
    [
      app: :my_app,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.2"}
    ]
  end
end
