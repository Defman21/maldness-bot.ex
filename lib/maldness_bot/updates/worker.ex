defmodule MaldnessBot.Updates.Worker do
  require Logger
  use GenServer

  # Client API

  def start_link(chat_id) do
    GenServer.start_link(__MODULE__, [], name: via_tuple(chat_id))
  end

  def handle_update(pid, update) do
    GenServer.cast(pid, {:handle_update, update})
  end

  # Callback API

  @impl GenServer
  def init(state) do
    {:ok, state}
  end

  @impl GenServer
  def handle_cast({:handle_update, _update}, state) do
    {:noreply, state}
  end

  # Internal

  defp via_tuple(chat_id) do
    MaldnessBot.Registry.via_tuple({__MODULE__, chat_id})
  end
end
