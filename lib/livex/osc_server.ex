defmodule Livex.OSCServer do
  use GenServer
  require Logger
  alias OSC.Message

  @port 8000

  def start_link do
    GenServer.start_link __MODULE__, :ok, name: :osc_server
  end

  def init(:ok) do
    {:ok, udp} = :gen_udp.open(@port, [:binary, {:active, true}])
    {:ok, %{sockets: %{}, udp_socket: udp}}
  end

  def handle_info {:udp, _socket, sender_ip, sender_port, data}, state do
    broadcast Message.parse(data)
    {:noreply, state}
  end

  defp broadcast {addr, packets} do
    Logger.debug "[OSCServer] message addr: #{inspect addr} data: #{inspect packets}"
    [topic, event] = normalize_address(addr)
    Livex.Endpoint.broadcast! topic, event, Map.new(packets)
  end

  defp normalize_address(<<?/, address :: binary>>), do: String.split(address, "/", parts: 2)

end
