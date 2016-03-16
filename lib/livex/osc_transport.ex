defmodule Livex.OSCTransport do
  @behaviour Phoenix.Socket.Transport
  require Logger

  alias Phoenix.Socket.Broadcast
  alias Phoenix.Socket.Transport
  alias Phoenix.Transports.WebSocket
  alias Livex.OSCServer

  import Plug.Conn, only: [fetch_query_params: 1]

  defdelegate [
    ws_init(args),
    ws_terminate(reason, state),
    ws_close(state)
  ], to: WebSocket

  def default_config do
   [serializer: Phoenix.Transports.WebSocketSerializer,
    timeout: 60_000,
    transport_log: false,
    cowboy: Phoenix.Endpoint.CowboyWebSocket]
  end

  # def init(%Plug.Conn{method: "GET"} = conn, args) do
  def init(conn, args) do
    Logger.debug "[Livex.OSCTransport] -- init!!"

    conn
    |> Plug.Conn.fetch_query_params
    |> copy_peer_to_params
    |> WebSocket.init(args)
  end

  def ws_handle(opcode, payload, state) do
    resp = WebSocket.ws_handle(opcode, payload, state)
    Logger.info "\n[OSCTransport] -- ws handling\n#{inspect resp}"
    # a join has always a reply
    case resp do
      {:ok, state} -> :ok # sync_osc_server(state)
      {:reply, _args, state} -> sync_osc_server(state)
    end
    resp
  end

  def ws_info(msg, state) do
    case resp = WebSocket.ws_info(msg, state) do
      # an exit with channel pid cleanup has always a reply
      {cmd, state} -> :ok
      {:reply, _args, state} -> sync_osc_server state
    end
    resp
  end

  defp sync_osc_server state do
    Logger.debug "[OSCTransport] - sync state\n"
    OSCServer.update state.socket.id, state.socket, state.channels
  end

  defp copy_peer_to_params(%{remote_ip: ip, params: params}=conn) do
    Logger.debug "[Livex.OSCTransport] remote ip/ peer: #{inspect {ip, conn.peer}}"
    %{conn | params: Map.put(params, :__sender_ip__, hash_ip(ip))}
  end

  def hash_ip(_ip), do: 1234
end
