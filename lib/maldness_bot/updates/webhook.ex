defmodule MaldnessBot.Updates.Webhook do
  require Logger
  use Plug.Router

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  post "/" do
    case MaldnessBot.Updates.Server.handle_update(conn.body_params) do
      :ok -> send_resp(conn, 200, "OK")
      {:error, "not an update"} -> send_resp(conn, 400, "not an update")
      _ -> send_resp(conn, 500, "internal server error")
    end
  end
end
