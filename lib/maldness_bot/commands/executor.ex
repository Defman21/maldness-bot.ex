defmodule MaldnessBot.Commands.Executor do
  @commands %{
    "up" => MaldnessBot.Commands.Handlers.Up,
    "weather" => MaldnessBot.Commands.Handlers.Weather
  }

  @spec execute(String.t(), String.t(), map()) :: :ok | {:error, binary()}
  def execute(command, arg, update) do
    case Map.fetch(@commands, command) do
      {:ok, handler} -> handler.handle(arg, update)
      :error -> {:error, "command not found"}
    end
  end
end
