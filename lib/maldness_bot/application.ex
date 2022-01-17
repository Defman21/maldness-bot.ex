defmodule MaldnessBot.Application do
  use Application

  @impl true
  def start(_type, _args) do
    MaldnessBot.Supervisor.start_link()
  end
end
