ExUnit.start()

Application.put_env(:live_react, MyAppWeb.Endpoint,
  secret_key_base: String.duplicate("a", 64),
  live_view: [signing_salt: "aaaaaaaa"]
)

defmodule MyAppWeb.Router do
  use Phoenix.Router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {MyAppWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  scope "/", MyAppWeb do
    pipe_through(:browser)
    live("/live_react_example", LiveReactLive)
  end
end

defmodule MyAppWeb.ErrorView do
  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end

defmodule MyAppWeb.LayoutView do
  use Phoenix.Component

  def render("root.html", assigns) do
    ~H"""
    <!DOCTYPE html>
    <html>
      <head>
        <title>Test</title>
      </head>
      <body>
        <%= @inner_content %>
      </body>
    </html>
    """
  end
end

defmodule MyAppWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :live_react

  @session_options [
    store: :cookie,
    key: "_live_react_key",
    signing_salt: "your_signing_salt"
  ]

  socket("/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]])

  plug(Plug.Static,
    at: "/",
    from: :live_react,
    gzip: false,
    only: ~w(assets fonts images favicon.ico robots.txt)
  )

  plug(Plug.Session, @session_options)
  plug(MyAppWeb.Router)
end

defmodule MyAppWeb.LiveReactLive do
  use Phoenix.LiveView
  import LiveReact.Component

  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0)}
  end

  def handle_event("increment", %{"count" => count}, socket) do
    {:noreply, assign(socket, count: count)}
  end

  # Add this new clause to handle the event from the test
  def handle_event("increment", _params, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  def render(assigns) do
    ~H"""
    <h1>LiveReact Example</h1>
    <.react id="hello-world" component="HelloWorld" props={%{initialCount: @count}} handle_event="increment" />
    <p>Server-side count: <%= @count %></p>
    """
  end
end

Supervisor.start_link([MyAppWeb.Endpoint], strategy: :one_for_one)
