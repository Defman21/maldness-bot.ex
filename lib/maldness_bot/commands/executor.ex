defmodule MaldnessBot.Commands.Executor do
  @commands %{
    "up" => MaldnessBot.Commands.Handlers.Up,
    "weather" => MaldnessBot.Commands.Handlers.Weather,
    "afk" => MaldnessBot.Commands.Handlers.AfkEvent,
  }

  @spec execute(String.t(), String.t(), map()) :: :ok | {:error, binary()}
  def execute(command, arg, message) do
    case Map.fetch(@commands, command) do
      {:ok, handler} -> handler.handle(arg, message)
      :error -> {:error, "command not found"}
    end
  end
end
