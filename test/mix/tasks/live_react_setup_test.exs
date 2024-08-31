defmodule Mix.Tasks.LiveReact.SetupTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  alias Mix.Tasks.LiveReact.Setup

  @tmp_dir "tmp/live_react_test"

  setup do
    File.rm_rf!(@tmp_dir)
    File.mkdir_p!(@tmp_dir)
    File.mkdir_p!("#{@tmp_dir}/assets/js")
    File.mkdir_p!("#{@tmp_dir}/lib/my_app_web/live")
    File.mkdir_p!("#{@tmp_dir}/config")

    File.write!("#{@tmp_dir}/assets/package.json", ~s({"dependencies":{}}))
    File.write!("#{@tmp_dir}/assets/js/app.js", "// Existing app.js content")
    File.write!("#{@tmp_dir}/config/config.exs", "use Mix.Config\n")
    File.write!("#{@tmp_dir}/config/dev.exs", "use Mix.Config\n")

    on_exit(fn ->
      File.rm_rf!(@tmp_dir)
    end)

    Mix.Project.push(MixProject)
    :ok
  end

  test "run/1 creates all necessary files and updates existing ones" do
    output =
      capture_io(fn ->
        File.cd!(@tmp_dir, fn ->
          Setup.run([])
        end)
      end)

    assert File.exists?("#{@tmp_dir}/assets/react/HelloWorld.js")
    assert File.exists?("#{@tmp_dir}/assets/react/index.js")
    assert File.exists?("#{@tmp_dir}/lib/my_app_web/live/live_react_live.ex")

    assert File.read!("#{@tmp_dir}/assets/js/app.js") =~ "import LiveReact from \"live_react\""
    assert File.read!("#{@tmp_dir}/config/config.exs") =~ "LiveReact configuration"

    package_json = File.read!("#{@tmp_dir}/assets/package.json") |> Jason.decode!()
    assert package_json["dependencies"]["react"]
    assert package_json["dependencies"]["react-dom"]
    assert package_json["dependencies"]["live_react"]

    # Check if the output contains the expected instructions
    assert output =~ "LiveReact has been set up in your project!"
    assert output =~ "Run `mix deps.get`"
    assert output =~ "Run `npm install`"
    assert output =~ "Add the following to your router.ex:"
    assert output =~ "live \"/live_react_example\", LiveReactLive"
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
    []
  end
end
