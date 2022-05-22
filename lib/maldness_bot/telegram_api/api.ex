defmodule MaldnessBot.TelegramAPI.API do
  use GenServer

  @base_url "https://api.telegram.org/"
  @finch MaldnessBot.Finch
  @headers [
    {"content-type", "application/json"}
  ]

  # Client API
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def get_me do
    GenServer.call(__MODULE__, :get_me)
  end

  def get_updates(offset \\ nil, limit \\ nil, opts \\ []) do
    GenServer.call(__MODULE__, {:get_updates, offset, limit, opts})
  end

  def send_message(chat_id, text, opts \\ []) do
    GenServer.cast(__MODULE__, {:send_message, chat_id, text, opts})
  end

  def set_webhook(url, opts \\ []) do
    GenServer.cast(__MODULE__, {:set_webhook, url, opts})
  end

  def delete_webhook do
    GenServer.cast(__MODULE__, :delete_webhook)
  end

  def get_chat_administrators(chat_id) do
    GenServer.call(__MODULE__, {:get_chat_administrators, chat_id})
  end

  # Server API

  @impl GenServer
  def init(state) do
    {:ok, state}
  end

  @impl GenServer
  def handle_call(:get_me, _from, state) do
    {:ok, result} = req("getMe")

    {:reply, result, state}
  end

  @impl GenServer
  def handle_call({:get_updates, offset, limit, opts}, _from, state) do
    {:ok, result} = req("getUpdates", merge(opts, offset: offset, limit: limit))

    {:reply, result, state}
  end

  @impl GenServer
  def handle_call({:get_chat_administrators, chat_id}, _from, state) do
    case req("getChatAdministrators", %{chat_id: chat_id}) do
      {:ok, result} -> {:reply, result, state}
      {:error, "Bad Request: there are no administrators in the private chat"} ->
        {:reply, [%{"status" => "creator"}], state}
    end
  end

  @impl GenServer
  def handle_cast({:send_message, chat_id, text, opts}, state) do
    {:ok, _} = req("sendMessage", merge(opts, chat_id: chat_id, text: text))

    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:set_webhook, url, opts}, state) do
    {:ok, _} = req("setWebhook", merge(opts, url: url))

    {:noreply, state}
  end

  @impl GenServer
  def handle_cast(:delete_webhook, state) do
    {:ok, _} = req("deleteWebhook")

    {:noreply, state}
  end

  # Internal

  defp req(name, body \\ nil) do
    {:ok, %Finch.Response{body: body}} =
      Finch.build(:post, method(name), @headers, Jason.encode!(body))
      |> Finch.request(@finch)

    case Jason.decode!(body) do
      %{"ok" => true, "result" => result} -> {:ok, result}
      %{"ok" => false, "description" => error} -> {:error, error}
    end
  end

  defp bot_url do
    token =
      Application.fetch_env!(:maldness_bot, MaldnessBot.Telegram)
      |> Keyword.fetch!(:token)

    URI.merge(@base_url, "/bot#{token}/") |> to_string()
  end

  defp method(name) do
    URI.merge(bot_url(), name) |> to_string()
  end

  defp merge(opts, new_opts) do
    Keyword.merge(opts, new_opts) |> Enum.into(%{})
  end
end
