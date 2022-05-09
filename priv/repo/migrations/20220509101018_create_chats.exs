defmodule MaldnessBot.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :telegram_id, :bigint, unique: true
      add :language, :string, default: "en"
    end
  end
end
