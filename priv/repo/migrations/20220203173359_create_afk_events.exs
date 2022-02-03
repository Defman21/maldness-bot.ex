defmodule MaldnessBot.Repo.Migrations.CreateAfkEvents do
  use Ecto.Migration

  def change do
    create table(:afk_events) do
      add :started_at, :utc_datetime
      add :ended_at, :utc_datetime
      add :message, :text
      add :event_type, :integer
      add :user_id, references(:users)
    end
  end
end
