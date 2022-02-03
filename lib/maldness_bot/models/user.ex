defmodule MaldnessBot.Models.User do
  use Ecto.Schema

  schema "users" do
      field :telegram_uid, :integer
      field :is_paying, :boolean
      field :latitude, :float
      field :longitude, :float
      field :first_name, :string
      field :last_name, :string
      field :username, :string

      has_many :afk_events, MaldnessBot.Models.AfkEvent
  end
end
