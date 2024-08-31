defmodule LiveReact.IntegrationTest do
  use ExUnit.Case
  use Phoenix.ConnTest
  import Phoenix.LiveViewTest

  @endpoint MyAppWeb.Endpoint

  setup do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  test "LiveReact component renders and handles events", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/live_react_example")

    assert has_element?(view, "#hello-world")
    assert render(view) =~ "Count: 0"

    view |> element("#hello-world button") |> render_click()
    assert render(view) =~ "Count: 1"
    assert render(view) =~ "Server-side count: 1"
  end
end
