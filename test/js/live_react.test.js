import LiveReact from "../../priv/live_react";
import React from "react";
import { render } from "@testing-library/react";
import "@testing-library/jest-dom";

// Mock react-dom/client
jest.mock("react-dom/client", () => ({
  createRoot: jest.fn().mockReturnValue({
    render: jest.fn(),
    unmount: jest.fn(),
  }),
}));

const TestComponent = ({ initialCount, pushEvent }) => {
  const [count, setCount] = React.useState(initialCount);
  return (
    <div data-testid="test-component">
      <span data-testid="count">Count: {count}</span>
      <button
        onClick={() => {
          setCount((prevCount) => prevCount + 1);
          pushEvent("increment", { count: count + 1 });
        }}
      >
        Increment
      </button>
    </div>
  );
};

describe("LiveReact", () => {
  let hook;
  let mockPushEvent;

  beforeEach(() => {
    mockPushEvent = jest.fn();
    hook = Object.create(LiveReact);
    hook.el = document.createElement("div");
    hook.el.dataset.component = "TestComponent";
    hook.el.dataset.props = JSON.stringify({ initialCount: 0 });
    hook.pushEvent = mockPushEvent;

    window.LiveReactComponents = { TestComponent };

    // Mock the renderComponent method
    hook.renderComponent = jest.fn(() => {
      const TestComponent = window.LiveReactComponents.TestComponent;
      render(
        <TestComponent
          initialCount={hook.props.initialCount}
          pushEvent={hook.pushEvent}
        />,
        hook.el
      );
    });

    console.error = jest.fn();
  });

  test("mounts and renders the component once", () => {
    hook.mounted();
    expect(hook.root.render).toHaveBeenCalledTimes(1);
  });

  test("updates when props change", () => {
    hook.mounted();
    expect(hook.root.render).toHaveBeenCalledTimes(2);

    hook.el.dataset.props = JSON.stringify({ initialCount: 5 });
    hook.updated();
    expect(hook.root.render).toHaveBeenCalledTimes(3);

    // Call updated again with the same props, should not render
    hook.updated();
    expect(hook.root.render).toHaveBeenCalledTimes(3);
  });

  test("handles events from the React component", () => {
    hook.mounted();
    const event = new CustomEvent("react-event", {
      detail: { event: "increment", payload: { count: 1 } },
    });
    hook.el.dispatchEvent(event);
    expect(mockPushEvent).toHaveBeenCalledWith("increment", { count: 1 });
  });

  test("unmounts the component when destroyed", () => {
    hook.mounted();
    hook.destroyed();
    expect(hook.root.unmount).toHaveBeenCalled();
  });
});
