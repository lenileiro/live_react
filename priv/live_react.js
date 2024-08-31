import React from "react";
import ReactDOM from "react-dom/client";
class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    console.error("LiveReact component error:", error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return <h1>Something went wrong in the React component.</h1>;
    }

    return this.props.children;
  }
}

const LiveReact = {
  mounted() {
    this.props = JSON.parse(this.el.dataset.props || "{}");
    this.state = JSON.parse(this.el.dataset.state || "{}");
    this.root = ReactDOM.createRoot(this.el);
    this.renderComponent();
    this.handleEvents();
  },
  updated() {
    const newProps = JSON.parse(this.el.dataset.props || "{}");
    const newState = JSON.parse(this.el.dataset.state || "{}");
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
    const Component = window.LiveReactComponents[componentName];

    if (!Component) {
      console.error(`Component ${componentName} not found`);
      return;
    }

    const loading = this.el.querySelector(".live-react-loading");
    if (loading) loading.style.display = "none";

    this.root.render(
      <ErrorBoundary>
        <Component
          {...this.props}
          {...this.state}
          pushEvent={this.pushEvent.bind(this)}
        />
      </ErrorBoundary>
    );
  },
  handleEvents() {
    this.el.addEventListener("react-event", (e) => {
      const { event, payload } = e.detail;
      this.pushEvent(event, payload);
    });
  },
  destroyed() {
    if (this.root) {
      this.root.unmount();
    }
  },
};

export default LiveReact;
