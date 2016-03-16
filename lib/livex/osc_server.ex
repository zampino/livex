defmodule Livex.OSCServer do
  use GenServer
  require Logger
  alias OSC.Message

  @port 8000

  def update id, socket, channels do
    GenServer.call :osc_server, {:update, id, socket, channels}
  end

  def start_link do
    GenServer.start_link __MODULE__, :ok, name: :osc_server
  end

  def init(:ok) do
    {:ok, udp} = :gen_udp.open(@port, [:binary, {:active, true}])
    {:ok, %{sockets: %{}, udp_socket: udp}}
  end

  def handle_call {:update, id, socket, channels}, _from, state do
    sockets = Map.put state.sockets, id, {socket, channels}
    {:reply, :ok, %{state | sockets: sockets}}
  end

  def handle_info {:udp, _socket, sender_ip, sender_port, data}, state do
    # Logger.debug "[OSCServer] receiving mssg from: #{inspect {sender_ip, sender_port}}\n"
    route(Message.parse(data), ip_to_id(sender_ip), state.sockets)
    {:noreply, state}
  end

  def handle_info({:push, msg}, state) do
    #
    {:noreply, state}
  end

  defp route {addr, packets}, id, sockets do
    {socket, channels} = Map.get(sockets, id, {nil, %{}})
    Logger.debug "[OSCServer] routing for topic: #{addr}\ndata: #{inspect packets}\n to socket: #{inspect socket}\nwith channels: #{inspect channels}"

    channels[normalize_address addr]
    |> dispatch(packets)

    :ok
  end

  defp dispatch(nil, _packets), do: nil
  defp dispatch(pid, packets), do: send(pid, {:osc, packets})
  defp normalize_address(addr), do: String.lstrip(addr, ?/)
  defp ip_to_id(_ip), do: "users:#{1234}"

end
