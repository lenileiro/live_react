defmodule Mix.Tasks.LiveReact.Setup do
  use Mix.Task

  @shortdoc "Sets up LiveReact in your Phoenix project"

  @moduledoc """
  Sets up LiveReact in your Phoenix project.

  This task will:
  1. Update your config files
  2. Add necessary JavaScript files and React components
  3. Update your package.json
  4. Add a sample LiveView using LiveReact

  Run this task from your Phoenix project root:

      mix live_react.setup

  """

  @impl true
  def run(_) do
    app_name = Mix.Project.config()[:app]
    web_module = web_module(app_name)

    # 1. Update config files
    update_config_exs()
    update_dev_exs(app_name, web_module)

    # 2. Add JavaScript files and React components
    create_react_files()

    # 3. Update package.json
    update_package_json()

    # 4. Add sample LiveView
    create_sample_live_view(web_module)

    # 5. Copy live_react.js to vendor folder
    copy_live_react_js()

    # 6. Print final instructions
    print_instructions()
  end

  defp update_config_exs do
    config = """

    # LiveReact configuration
    config :esbuild,
      react: [
        args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets --external:/fonts/* --external:/images/* --loader:.js=jsx),
        cd: Path.expand("../assets", __DIR__),
        env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
      ]
    """

    append_to_file("config/config.exs", config)
  end

  defp update_dev_exs(app_name, web_module) do
    dev_config =
      """
      config :#{app_name}, #{web_module}.Endpoint,
        watchers: [
          esbuild: {Esbuild, :install_and_run, [:react, ~w(--sourcemap=inline --watch)]}
        ]
      """

    append_to_file("config/dev.exs", dev_config)
  end

  defp create_react_files do
    # Create react directory
    File.mkdir_p!("assets/react")

    # Create HelloWorld.js
    File.write!("assets/react/HelloWorld.jsx", """
    import React, { useState } from 'react';

    const HelloWorld = ({ initialCount = 0, pushEvent }) => {
      const [count, setCount] = useState(initialCount);

      const increment = () => {
        const newCount = count + 1;
        setCount(newCount);
        pushEvent("increment", { count: newCount });
      };

      return (
        <>
          <h1>Hello, World!</h1>
          <p>Count: {count}</p>
          <button onClick={increment}>Increment</button>
        </>
      );
    };

    export default HelloWorld;
    """)

    # Create index.js
    File.write!("assets/react/index.js", """
    import HelloWorld from './HelloWorld';

    export default {
      HelloWorld
    };
    """)

    # Update app.js
    append_to_file("assets/js/app.js", """

    import LiveReact from "../vendor/live_react";
    import ReactComponents from "../react";

    // Define your React components globally
    window.LiveReactComponents = ReactComponents;

    let Hooks = {};
    Hooks.LiveReact = LiveReact;

    let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}});
    """)
  end

  defp update_package_json do
    package_json_path = "assets/package.json"

    package_json =
      case File.read(package_json_path) do
        {:ok, content} -> Jason.decode!(content)
        {:error, _} -> %{}
      end

    package_json =
      Map.update(package_json, "dependencies", %{}, fn deps ->
        deps
        |> Map.put("react", "^18.2.0")
        |> Map.put("react-dom", "^18.2.0")
        |> Map.put("live_react", "^0.1.0")
      end)

    File.write!(package_json_path, Jason.encode!(package_json, pretty: true))
  end

  defp create_sample_live_view(web_module) do
    content = """
    defmodule #{web_module}.LiveReactLive do
      use #{web_module}, :live_view
      import LiveReact.Component

      def mount(_params, _session, socket) do
        {:ok, assign(socket, count: 0)}
      end

      def handle_event("increment", %{"count" => count}, socket) do
        {:noreply, assign(socket, count: count)}
      end

      def render(assigns) do
        ~H\"\"\"
        <h1>LiveReact Example</h1>
        <.react id="hello-world" component="HelloWorld" props={%{initialCount: @count}} handle_event="increment" />
        <p>Server-side count: <%= @count %></p>
        \"\"\"
      end
    end
    """

    target_dir = "lib/#{Macro.underscore(web_module)}/live"

    File.mkdir_p!(target_dir)

    File.write!("#{target_dir}/live_react_live.ex", content)
  end

  defp copy_live_react_js do
    target_dir = "assets/vendor"
    target_path = Path.join(target_dir, "live_react.js")

    File.mkdir_p!(target_dir)

    content = """
    import React from 'react';
    import ReactDOM from 'react-dom/client';

    const LiveReact = {
      mounted() {
        this.props = JSON.parse(this.el.dataset.props || '{}');
        this.state = JSON.parse(this.el.dataset.state || '{}');
        this.root = ReactDOM.createRoot(this.el);
        this.renderComponent();
      },
      updated() {
        const newProps = JSON.parse(this.el.dataset.props || '{}');
        const newState = JSON.parse(this.el.dataset.state || '{}');
        if (JSON.stringify(this.props) !== JSON.stringify(newProps) ||
            JSON.stringify(this.state) !== JSON.stringify(newState)) {
          this.props = newProps;
          this.state = newState;
          this.renderComponent();
        }
      },
      renderComponent() {
        const componentName = this.el.dataset.component;
        const Component = window.LiveReactComponents[componentName];

        if (!Component) {
          console.error(`Component ${componentName} not found`);
          return;
        }

        this.root.render(
          React.createElement(Component, {
            ...this.props,
            ...this.state,
            pushEvent: this.pushEvent.bind(this)
          })
        );
      },
      destroyed() {
        if (this.root) {
          this.root.unmount();
        }
      }
    };

    export default LiveReact;
    """

    File.write!(target_path, content)
    Mix.shell().info("Created live_react.js at #{target_path}")
  end

  defp print_instructions do
    Mix.shell().info("""

    LiveReact has been set up in your project!

    To complete the setup:

    1. Run `mix deps.get` to fetch the LiveReact dependency.
    2. Run `npm install` in your `assets` directory to install React.
    3. Add the following to your router.ex:

       live "/live_react_example", LiveReactLive

    4. Start your Phoenix server and visit /live_react_example to see LiveReact in action!

    Enjoy using LiveReact!
    """)
  end

  defp web_module(app_name) do
    app_name
    |> to_string()
    |> Macro.camelize()
    |> Kernel.<>("Web")
  end

  defp append_to_file(path, content) do
    File.write!(path, File.read!(path) <> content)
  end
end
