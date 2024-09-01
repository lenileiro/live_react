import React, { Suspense, lazy, useState, useEffect, useRef } from "react";
import ReactDOM from "react-dom/client";

const DEFAULT_LOADING_COMPONENT = () => <div>Loading...</div>;

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    console.error("LiveReact component error:", error, errorInfo);
    if (this.props.onError) {
      this.props.onError(error, errorInfo);
    }
  }

  render() {
    if (this.state.hasError) {
      return (
        <div style={{ color: "red", padding: "10px", border: "1px solid red" }}>
          <h3>Error in React component:</h3>
          <p>{this.state.error.message}</p>
        </div>
      );
    }
    return this.props.children;
  }
}

const useDeepCompareMemoize = (value) => {
  const ref = useRef();
  if (JSON.stringify(value) !== JSON.stringify(ref.current)) {
    ref.current = value;
  }
  return ref.current;
};

const ComponentWrapper = ({
  componentName,
  props,
  state,
  pushEvent,
  onError,
}) => {
  const [LazyComponent, setLazyComponent] = useState(null);
  const memoizedProps = useDeepCompareMemoize(props);
  const memoizedState = useDeepCompareMemoize(state);

  useEffect(() => {
    const importComponent = async () => {
      try {
        // TODO: make it configurable
        const module = await import(`../../react/${componentName}`);
        const Component =
          module.default ||
          window.LiveReactComponents[componentName] ||
          module[componentName];

        if (!Component) {
          throw new Error(`Component ${componentName} not found in the module`);
        }

        setLazyComponent(() => Component);
      } catch (error) {
        if (error.code === "MODULE_NOT_FOUND") {
          throw new Error(`Component ${componentName} not found`);
        }
        throw error;
      }
    };

    importComponent();
  }, [componentName]);

  if (!LazyComponent) {
    return <DEFAULT_LOADING_COMPONENT />;
  }

  return (
    <LazyComponent
      {...memoizedProps}
      {...memoizedState}
      pushEvent={pushEvent}
    />
  );
};

const LiveReact = {
  mounted() {
    this.props = this.parseJSON(this.el.dataset.props, {});
    this.state = this.parseJSON(this.el.dataset.state, {});
    this.root = ReactDOM.createRoot(this.el);
    this.renderComponent();
    this.handleEvents();
  },

  updated() {
    const newProps = this.parseJSON(this.el.dataset.props, {});
    const newState = this.parseJSON(this.el.dataset.state, {});
    if (
      JSON.stringify(this.props) !== JSON.stringify(newProps) ||
      JSON.stringify(this.state) !== JSON.stringify(newState)
    ) {
      this.props = newProps;
      this.state = newState;
      this.renderComponent();
    }
  },

  renderComponent() {
    const componentName = this.el.dataset.component;

    this.root.render(
      <ErrorBoundary onError={this.handleError.bind(this)}>
        <Suspense fallback={<DEFAULT_LOADING_COMPONENT />}>
          <ComponentWrapper
            componentName={componentName}
            props={this.props}
            state={this.state}
            pushEvent={this.pushEvent.bind(this)}
            onError={this.handleError.bind(this)}
          />
        </Suspense>
      </ErrorBoundary>
    );
  },

  handleEvents() {
    this.el.addEventListener("react-event", (e) => {
      const { event, payload } = e.detail;
      this.pushEvent(event, payload);
    });
  },

  handleError(error, errorInfo) {
    console.error("LiveReact error:", error, errorInfo);
    this.pushEvent("live_react_error", {
      error: error.message,
      componentName: this.el.dataset.component,
    });
  },

  parseJSON(json, defaultValue) {
    try {
      return JSON.parse(json || "null") || defaultValue;
    } catch (error) {
      console.error("Error parsing JSON:", error);
      return defaultValue;
    }
  },

  destroyed() {
    if (this.root) {
      this.root.unmount();
    }
  },
};

export default LiveReact;
