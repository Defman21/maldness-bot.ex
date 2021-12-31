defmodule MaldnessBot.Updates.Webhook do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/:chat_id/:id" do
    upd = %{
      id: id,
      chat_id: chat_id
    }

    MaldnessBot.Updates.Server.handle_update(upd)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{ok: true, update: upd}))
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
