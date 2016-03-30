defmodule Livex.RotorChannel do
  use Livex.Web, :channel
  require Logger
  def join("rotor:" <> idx, payload, socket) do
    Logger.info("joining #{idx} ::: #{inspect socket}")
    {:ok, socket}
  end
end
