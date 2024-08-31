defmodule LiveReact do
  @moduledoc """
  LiveReact allows seamless integration of React components with Phoenix LiveView.
  """

  def javascript_path do
    Application.app_dir(:live_react, "priv/static/live_react.js")
  end
end
