defmodule MaldnessBot.Commands.Handlers.AfkEvent do
  require Logger

  alias MaldnessBot.Models.{User, AfkEvent}
  alias MaldnessBot.TelegramAPI.API
  alias MaldnessBot.AfkCache

  def handle(arg, %{"from" => from, "chat" => chat}, %{command: command}) do
    get_user(from)
    |> create_event(arg, command)
    |> save_to_cache()
    |> send_message(chat, from)
  end

  defp get_user(from) do
    case User.get_by_telegram(from["id"]) do
      nil -> User.create_from_telegram(from)
      user -> user
    end
  end

  defp create_event(user, message, command) do
    {
      User.add_afk_event(user, %AfkEvent{
        started_at: DateTime.utc_now() |> DateTime.truncate(:second),
        message: message,
        event_type: AfkEvent.type(String.to_atom(command))
      }),
      user
    }
  end

  defp save_to_cache({event, user}) do
    AfkCache.insert(user.telegram_uid, event.id)
    event
  end

  defp send_message(event, chat, from) do
    API.send_message(
      chat["id"],
      AfkEvent.format_message(event, :in, from)
    )

    :ok
  end
end
