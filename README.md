# LiveReact

LiveReact is a powerful library that seamlessly integrates React components with Phoenix LiveView. It allows you to use React components within your LiveView applications, combining the best of both worlds.

## Features

- Easy integration of React components in Phoenix LiveView
- Bi-directional communication between LiveView and React components
- Automatic prop and state management
- Error boundary for React components
- Simple setup process

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `live_react` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:live_react, "~> 0.1.0"}
  ]
end
```

Then run `mix deps.get` to fetch the dependency.

## Setup

To set up LiveReact in your Phoenix project, run the following mix task:

```bash
mix live_react.setup
```

This task will:

1. Update your config files
2. Add necessary JavaScript files and React components
3. Update your package.json
4. Add a sample LiveView using LiveReact

After running the setup task, follow these steps:

1. Run `npm install` in your `assets` directory to install React and other dependencies.
2. Add the following to your `router.ex`:

```elixir
live "/live_react_example", LiveReactLive
```

3. Start your Phoenix server and visit `/live_react_example` to see LiveReact in action!

## Usage

### Basic Component

To use a React component in your LiveView, use the `react` function component provided by LiveReact:

```elixir
import LiveReact.Component

def render(assigns) do
  ~H"""
  <.react
    id="hello-world"
    component="HelloWorld"
    props={%{initialCount: @count}}
    handle_event="increment"
  />
  """
end
```

React component

```js
import React, { useState, useEffect } from "react";

const HelloWorld = ({ initialCount, pushEvent }) => {
  const [count, setCount] = useState(initialCount);

  useEffect(() => {
    setCount(initialCount);
  }, [initialCount]);

  const handleIncrement = () => {
    const newCount = count + 1;
    setCount(newCount);
    pushEvent("increment", { count: newCount });
  };

  return (
    <div>
      <h2>Hello from React!</h2>
      <p>Count: {count}</p>
      <button onClick={handleIncrement}>Increment</button>
    </div>
  );
};

export default HelloWorld;
```

### Handling Events

To handle events from the React component, define a `handle_event` function in your LiveView:

```elixir
def handle_event("increment", %{"count" => count}, socket) do
  {:noreply, assign(socket, count: count)}
end
```

## Configuration

LiveReact uses esbuild for bundling React components. Add the following configuration to your `config/config.exs`:

```elixir
config :esbuild,
  react: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets --external:/fonts/* --external:/images/* --loader:.js=jsx),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]
```

And update your `config/dev.exs`:

```elixir
config :your_app, YourAppWeb.Endpoint,
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:react, ~w(--sourcemap=inline --watch)]}
  ]
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

LiveReact is released under the MIT License. See the LICENSE file for details.
