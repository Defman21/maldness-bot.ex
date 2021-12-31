defmodule MaldnessBot.Updates.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl Supervisor
  def init(:ok) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: MaldnessBot.Updates.Webhook, options: [port: 8080]},
      MaldnessBot.Updates.Server
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
