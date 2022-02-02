defmodule MaldnessBot.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :telegram_uid, :bigint, unique: true
      add :is_paying, :boolean, default: false
      add :latitude, :float
      add :longitude, :float
      add :first_name, :string
      add :last_name, :string
      add :username, :string
    end
  end
end
