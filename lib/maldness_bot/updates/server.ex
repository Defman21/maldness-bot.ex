defmodule MaldnessBot.Updates.Server do
  use DynamicSupervisor
  require Logger
  alias MaldnessBot.Updates.Worker

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def handle_update(%{"update_id" => _} = update) do
    update["chat"]["id"]
    |> get_worker_pid()
    |> Worker.handle_update(update)
  end

  def handle_update(_), do: {:error, "not an update"}

  defp get_worker_pid(chat_id) do
    case DynamicSupervisor.start_child(__MODULE__, {Worker, chat_id}) do
      {:ok, pid} ->
        Logger.debug("Started a new worker for chat #{chat_id}", pid: pid)
        pid

      {:error, {:already_started, pid}} ->
        Logger.debug("Worker for chat #{chat_id} exists", pid: pid)
        pid
    end
  end
end
