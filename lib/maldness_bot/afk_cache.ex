defmodule MaldnessBot.AfkCache do
  require Logger
  use GenServer

  # Client API

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @spec insert(pos_integer(), pos_integer()) :: :ok
  def insert(user_id, event_id) do
    GenServer.cast(__MODULE__, {:insert, user_id, event_id})
  end

  @spec delete(pos_integer()) :: :ok
  def delete(user_id) do
    GenServer.cast(__MODULE__, {:delete, user_id})
  end

  @spec get(pos_integer()) :: pos_integer() | nil
  def get(user_id) do
    case GenServer.call(__MODULE__, {:get, user_id}) do
      {_, event_id} -> event_id
      nil -> nil
    end
  end

  # Callback API

  @impl GenServer
  def init(:ok) do
    table = :ets.new(:afk_cache, [:set, :protected])
    Logger.debug("initialized afk cache")
    {:ok, table}
  end

  @impl GenServer
  def handle_cast({:insert, user_id, event_id}, table) do
   table |> :ets.insert({user_id, event_id})
   {:noreply, table}
  end

  @impl GenServer
  def handle_cast({:delete, user_id}, table) do
    table |> :ets.delete(user_id)
    {:noreply, table}
  end

  @impl GenServer
  def handle_call({:get, user_id}, _from, table) do
    {:reply, table |> :ets.lookup(user_id) |> List.first(), table}
  end
end
