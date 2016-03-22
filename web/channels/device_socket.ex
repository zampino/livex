defmodule Livex.DeviceSocket do
  use Phoenix.Socket
  require Logger

  ## Channels
  channel "fader:*", Livex.FaderChannel
  # channel "xy:*", Livex.XYChannel
  channel "monitor", Livex.MonitorChannel
  channel "rotor:*", Livex.RotorChannel
  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket #Livex.OSCTransport

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(params, socket) do
    {:ok, assign(socket, :user_id, params["user_id"])}
  end
  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Livex.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(socket), do: "monitor:#{socket.assigns.user_id}"
end
