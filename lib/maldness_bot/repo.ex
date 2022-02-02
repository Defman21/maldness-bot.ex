defmodule MaldnessBot.Repo do
  use Ecto.Repo,
    otp_app: :maldness_bot,
    adapter: Ecto.Adapters.Postgres
end
