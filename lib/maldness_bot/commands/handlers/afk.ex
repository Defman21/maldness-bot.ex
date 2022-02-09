defmodule MaldnessBot.Commands.Handlers.AfkEvent do
  require Logger

  alias MaldnessBot.Models.{User, AfkEvent}
  alias MaldnessBot.TelegramAPI.API

  def handle(arg, %{"message_id" => mes_id, "from" => from, "chat" => chat}) do
    user = case User.get_by_telegram(from["id"]) do
      nil -> User.create_from_telegram(from)
      user -> user
    end

    event = User.add_afk_event(user, %AfkEvent{
      started_at: DateTime.utc_now() |> DateTime.truncate(:second),
      message: arg,
      event_type: AfkEvent.type(:afk),
    })

    Logger.debug("Created afk event #{event.id} for user #{user.id}")

    API.send_message(chat["id"], "created afk event #{event.id}", reply_to: mes_id)

    :ok
  end
end
