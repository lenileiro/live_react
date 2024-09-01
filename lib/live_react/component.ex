defmodule LiveReact.Component do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr(:id, :string, required: true)
  attr(:component, :string, required: true)
  attr(:props, :map, default: %{})
  attr(:state, :map, default: %{})
  attr(:handle_event, :string, default: nil)
  attr(:loading, :string, default: "Loading...")
  slot(:inner_block)

  def react(assigns) do
    ~H"""
    <div id={@id} phx-hook="LiveReact" phx-update="ignore"
         data-component={@component}
         data-props={Jason.encode!(@props)}
         data-state={Jason.encode!(@state)}>
      <%= if @handle_event do %>
        <div phx-click={JS.push(@handle_event, value: %{id: @id})} style="display: none;"></div>
      <% end %>
      <div class="live-react-loading">
        <%= @loading %>
      </div>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
