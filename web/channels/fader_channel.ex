defmodule Livex.FaderChannel do
  use Livex.Web, :channel
  require Logger

  def join("fader:" <> direction, _payload, socket) do
    Logger.debug "joined #{direction}"
    {:ok, socket.id, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (fader:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # This is invoked every time a notification is being broadcast
  # to the client. The default implementation is just to push it
  # downstream but one could filter or change the event.
  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  def handle_info {:osc, data}, socket do
    push socket, "data", Map.new(data)
    Logger.debug "[OSC INFO] -- #{inspect data}"
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
