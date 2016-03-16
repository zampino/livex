defmodule Livex.DeviceSocket do
  use Phoenix.Socket
  require Logger
  
  ## Channels
  channel "fader:*", Livex.FaderChannel

  ## Transports
  transport :websocket, Livex.OSCTransport

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
    Logger.info "[Livex.DeviceSocket] - connect"
    {:ok, assign(socket, :user_id, params[:__sender_ip__])}
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
  def id(socket), do: "users:#{socket.assigns.user_id}"
end
