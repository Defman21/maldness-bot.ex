defmodule MaldnessBot.Commands.Handlers.Up do
  alias MaldnessBot.TelegramAPI.API

  def handle(_, update) do
    API.send_message(update["message"]["chat"]["id"], "I'm alive")
    :ok
  end
end
