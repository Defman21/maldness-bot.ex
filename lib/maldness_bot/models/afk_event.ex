defmodule MaldnessBot.Models.AfkEvent do
  use Ecto.Schema

  schema "afk_events" do
    field :started_at, :utc_datetime
    field :ended_at, :utc_datetime
    field :message, :string
    field :event_type, :integer
    belongs_to :user, MaldnessBot.Models.User
  end
end
