defmodule MaldnessBot.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    children = [
      {MaldnessBot.Repo, []},
      MaldnessBot.Registry,
      MaldnessBot.Updates.Supervisor,
      {Finch, name: MaldnessBot.Finch},
      MaldnessBot.TelegramAPI.API,
      MaldnessBot.AfkCache,
      {Task.Supervisor, name: MaldnessBot.UpdatesTaskSupervisor}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
