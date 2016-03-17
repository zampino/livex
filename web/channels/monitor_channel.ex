defmodule Livex.MonitorChannel do
  use Livex.Web, :channel
  require Logger

  def join("monitor", _payload, socket) do
    if socket.id, do: socket.endpoint.subscribe(self, socket.id)
    {:ok, socket.id, socket}
  end

  def handle_info msg, socket do
    push socket, msg.event, msg.payload
    Logger.debug "[FaderChannel] handle_info -- #{inspect msg}"
    {:noreply, socket}
  end
end
