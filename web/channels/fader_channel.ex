defmodule Livex.FaderChannel do
  use Livex.Web, :channel
  require Logger

  # intercept ["fade"]

  def join("fader:" <> direction, _payload, socket) do
    Logger.debug "joined #{direction}"
    # if socket.id, do: socket.endpoint.subscribe(self, socket.id)
    {:ok, socket.id, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (fader:lobby).
  def handle_in(msg, payload, socket) do
    # broadcast socket, "shout", payload
    Logger.debug "[FaderChannel] handle_in -- #{inspect {msg, payload}}"
    {:noreply, socket}
  end

  # This is invoked every time a notification is being broadcast
  # to the client. The default implementation is just to push it
  # downstream but one could filter or change the event.
  def handle_out(event, payload, socket) do
    Logger.info "\n[Livex.FaderChannel] -- receiving broadcast"
    # push socket, event, payload
    {:noreply, socket}
  end

  def handle_info msg, socket do
    push socket, msg.event, msg.payload
    Logger.debug "[FaderChannel] handle_info -- #{inspect msg}"
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
