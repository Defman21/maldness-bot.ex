defmodule MaldnessBot.Commands.Parser do
  def parse_message(%{"entities" => entities} = message) when not is_nil(entities) do
    case entities
         |> Enum.filter(&is_command?/1)
         |> List.first() do
      %{"offset" => 0, "length" => length} -> parse_command(message["text"], length)
      _ -> {:error, "no command in the message"}
    end
  end

  defp is_command?(entity), do: entity["type"] == "bot_command"

  defp parse_command(text, length) do
    cmd = String.slice(text, 1, length - 1)

    case String.contains?(cmd, "@") do
      false ->
        {:ok, cmd}

      true ->
        bot_name = Application.fetch_env!(:maldness_bot, :name)
        {:ok, String.slice(cmd, 0..(-String.length(bot_name) - 1))}
    end
  end
end
