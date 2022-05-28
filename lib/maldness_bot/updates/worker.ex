defmodule MaldnessBot.Updates.Worker do
  require Logger
  use GenServer
  alias MaldnessBot.Commands.Parser, as: CommandParser
  alias MaldnessBot.AfkCache
  alias MaldnessBot.Models.{Chat, AfkEvent}

  # Client API

  def start_link(chat_id) do
    GenServer.start_link(__MODULE__, %{chat_id: chat_id}, name: via_tuple(chat_id))
  end

  def handle_update(pid, update) do
    GenServer.cast(pid, {:handle_update, update})
  end

  # Callback API

  @impl GenServer
  def init(%{chat_id: chat_id} = state) do
    chat = Chat.get_or_create(chat_id)
    _ = Gettext.put_locale(MaldnessBot.Gettext, chat.language)
    {:ok, Map.put(state, :language, chat.language)}
  end

  defp process_afk_event(
         %{
           "message_id" => message_id,
           "chat" => %{"id" => chat_id},
           "from" => %{"id" => user_id} = from
         },
         lang
       ) do
    {:ok, _} =
      Task.Supervisor.start_child(MaldnessBot.UpdatesTaskSupervisor, fn ->
        _ = Gettext.put_locale(MaldnessBot.Gettext, lang)

        with event_id when is_integer(event_id) <- AfkCache.get(user_id) do
          AfkCache.delete(user_id)

          event = MaldnessBot.Models.AfkEvent.close(event_id)

          MaldnessBot.TelegramAPI.API.send_message(
            chat_id,
            AfkEvent.format_message(event, :out, from),
            reply_to_message_id: message_id
          )
        end
      end)

    :ok
  end

  @impl GenServer
  def handle_cast({:handle_update, %{"message" => message}}, state) do
    :ok = process_afk_event(message, state.language)

    case CommandParser.parse_message(message) do
      {:ok, command, arg} ->
        case MaldnessBot.Commands.Executor.execute(command, arg, message, state) do
          :ok -> {:noreply, state}
          :restart -> {:stop, :normal, state}
        end

      {:error, "no command in the message"} ->
        {:noreply, state}

      {:error, "not an admin"} ->
        {:noreply, state}
    end
  end

  @impl GenServer
  def handle_cast({:handle_update, update}, state) do
    Logger.debug("unhandled update: #{inspect(update)}")
    {:noreply, state}
  end

  # Internal

  defp via_tuple(chat_id) do
    MaldnessBot.Registry.via_tuple({__MODULE__, chat_id})
  end
end
