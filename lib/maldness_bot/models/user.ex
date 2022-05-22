defmodule MaldnessBot.Models.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:telegram_uid, :integer)
    field(:is_paying, :boolean)
    field(:latitude, :float)
    field(:longitude, :float)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:username, :string)

    has_many(:afk_events, MaldnessBot.Models.AfkEvent)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:latitude, :longitude, :first_name, :last_name, :username, :is_paying])
  end

  def add_afk_event(user, event) do
    user
    |> Ecto.build_assoc(:afk_events, event)
    |> MaldnessBot.Repo.insert!()
  end

  def get_by_telegram(id) do
    __MODULE__ |> MaldnessBot.Repo.get_by(telegram_uid: id)
  end

  def set_location(user_id, latitude, longitude) do
    case get_by_telegram(user_id) do
      nil ->
        :ok

      user ->
        user
        |> changeset(%{latitude: latitude, longitude: longitude})
        |> MaldnessBot.Repo.update!()
    end
  end

  def create_from_telegram(from) do
    %__MODULE__{
      telegram_uid: from["id"],
      first_name: from["first_name"],
      last_name: from["last_name"],
      username: from["username"],
      is_paying: false,
      latitude: nil,
      longitude: nil
    }
    |> MaldnessBot.Repo.insert!()
  end
end
