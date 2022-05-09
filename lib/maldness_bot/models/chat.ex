defmodule MaldnessBot.Models.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chats" do
    field(:telegram_id, :integer)
    field(:language, :string)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:language])
  end

  @spec get_by_telegram(pos_integer()) :: __MODULE__ | nil
  def get_by_telegram(id) do
    __MODULE__ |> MaldnessBot.Repo.get_by(telegram_id: id)
  end

  @spec create(pos_integer(), String.t()) :: __MODULE__
  def create(telegram_id, language \\ "en") do
    %__MODULE__{
      telegram_id: telegram_id,
      language: language
    }
    |> MaldnessBot.Repo.insert!()
  end

  def get_or_create(telegram_id, language \\ "en") do
    case get_by_telegram(telegram_id) do
      nil -> create(telegram_id, language)
      chat -> chat
    end
  end

  def set_language(telegram_id, language) do
    MaldnessBot.Repo.get_by!(__MODULE__, telegram_id: telegram_id)
    |> changeset(%{language: language})
    |> MaldnessBot.Repo.update!()
  end
end
