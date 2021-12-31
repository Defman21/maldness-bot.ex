defmodule MaldnessBot.Application do
  use Application

  @impl true
  def start(_type, _args) do
    MaldnessBot.Supervisor.start_link(
      strategy: :one_for_one,
      name: MaldnessBot.Supervisor
    )
  end
end
