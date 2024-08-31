defmodule LiveReact.IntegrationTest do
  use ExUnit.Case

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  @endpoint MyAppWeb.Endpoint

  setup do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  test "LiveReact component renders and handles events", %{conn: conn} do
    {:ok, view, html} = live(conn, "/live_react_example")

    assert html =~ "LiveReact Example"
    assert has_element?(view, "#hello-world")
    assert html =~ "Server-side count: 0"

    # Wait for the React component to render
    :timer.sleep(500)

    # Trigger the increment event directly
    assert view
           |> element("#hello-world div[phx-click]")
           |> render_click() =~ "Server-side count: 1"
  end
end
