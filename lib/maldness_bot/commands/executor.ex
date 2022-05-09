defmodule MaldnessBot.Commands.Executor do
  @commands %{
    "up" => MaldnessBot.Commands.Handlers.Up,
    "weather" => MaldnessBot.Commands.Handlers.Weather,
    "afk" => MaldnessBot.Commands.Handlers.AfkEvent,
    "set_language" => MaldnessBot.Commands.Handlers.SetLanguage
  }

  @spec execute(String.t(), String.t(), map()) :: :ok | :restart | {:error, binary()}
  def execute(command, arg, message) do
    case Map.fetch(@commands, command) do
      {:ok, handler} -> handler.handle(arg, message)
      :error -> {:error, "command not found"}
    end
  end
end
