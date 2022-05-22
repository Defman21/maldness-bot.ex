defmodule MaldnessBot.Commands.Handlers.SetLocation do
  require Logger

  alias MaldnessBot.Models.User

  def handle(
        _arg,
        %{
          "from" => %{"id" => user_id},
          "reply_to_message" => %{
            "location" => %{"longitude" => longitude, "latitude" => latitude}
          }
        },
        _state
      ) do
    User.set_location(user_id, latitude, longitude)
    :ok
  end
end
