defmodule LiveReact.ComponentTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  alias LiveReact.Component

  test "react/1 renders the component correctly" do
    component = %{
      id: "test-component",
      component: "TestComponent",
      props: %{test: "value"},
      state: %{count: 0},
      handle_event: "test-event"
    }

    html = render_component(&Component.react/1, component)

    assert html =~ ~s(id="test-component")
    assert html =~ ~s(phx-hook="LiveReact")
    assert html =~ ~s(data-component="TestComponent")
    assert html =~ ~s(data-props="{&quot;test&quot;:&quot;value&quot;}")
    assert html =~ ~s(data-state="{&quot;count&quot;:0}")
    assert html =~ ~s(phx-click=)
    assert html =~ "test-event"
  end
end
