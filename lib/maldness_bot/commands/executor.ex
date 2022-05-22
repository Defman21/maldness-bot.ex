defmodule MaldnessBot.Commands.Executor do
  @commands %{
    "up" => [handler: MaldnessBot.Commands.Handlers.Up, admin_only: false],
    "weather" => [handler: MaldnessBot.Commands.Handlers.Weather, admin_only: false],
    "afk" => [handler: MaldnessBot.Commands.Handlers.AfkEvent, admin_only: false],
    "set_language" => [handler: MaldnessBot.Commands.Handlers.SetLanguage, admin_only: true]
  }

  @creator_id Application.compile_env!(:maldness_bot, MaldnessBot.Telegram) |> Keyword.fetch!(:creator_id)

  @spec execute(String.t(), String.t(), map(), map()) :: :ok | :restart | {:error, binary()}
  def execute(command, arg, message, state) do
    case Map.fetch(@commands, command) do
      {:ok, handler: handler, admin_only: admin_only} ->
        handle_call(handler, arg, message, state, admin_only: admin_only)
      :error -> {:error, "command not found"}
    end
  end

  defp handle_call(handler, arg, message, state, admin_only: false), do: handler.handle(arg, message, state)
  defp handle_call(handler, arg, message, state, admin_only: true) do
    admins = fetch_admins(message["chat"]["id"])
    case message["user"]["id"] in admins do
      true -> handler.handle(arg, message, state)
      false -> {:error, "not an admin"}
    end
  end

  @spec fetch_admins(integer()) :: list(integer())
  def fetch_admins(chat_id) do
    MaldnessBot.TelegramAPI.API.get_chat_administrators(chat_id)
    |> Enum.filter(&is_admin?/1)
    |> Enum.map(&(&1["user"]["id"]))
  end

  defp is_admin?(%{"status" => "creator"}), do: true
  defp is_admin?(%{"status" => "administrator"}), do: true
  defp is_admin?(%{"user" => %{"id" => @creator_id}}), do: true
  defp is_admin?(_), do: false
end
