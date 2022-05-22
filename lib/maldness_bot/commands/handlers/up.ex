defmodule MaldnessBot.Commands.Handlers.Up do
  alias MaldnessBot.TelegramAPI.API

  def handle(_arg, message, _state) do
    API.send_message(message["chat"]["id"], "I'm alive")
    :ok
  end
end
