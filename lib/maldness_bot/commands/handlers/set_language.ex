defmodule MaldnessBot.Commands.Handlers.SetLanguage do
  require Logger

  alias MaldnessBot.Models.Chat

  def handle(lang, %{"chat" => %{"id" => chat_id}}) when lang in ["ru", "en"] do
    Chat.set_language(chat_id, lang)
    :restart
  end
end
