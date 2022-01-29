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

  @spec extract_arg(String.t(), pos_integer()) :: String.t() | nil
  defp extract_arg(text, cmd_len) do
    text_len = String.length(text)

    case text_len == cmd_len do
      true -> nil
      false -> String.slice(text, cmd_len + 1, text_len - cmd_len)
    end
  end

  defp parse_command(text, length) do
    cmd = String.slice(text, 1, length - 1)
    arg = extract_arg(text, length)

    case String.contains?(cmd, "@") do
      false ->
        {:ok, cmd, arg}

      true ->
        bot_name = Application.fetch_env!(:maldness_bot, :name)
        {:ok, String.slice(cmd, 0..(-String.length(bot_name) - 1)), arg}
    end
  end
end
