defmodule MaldnessBot.Models.AfkEvent do
  use Ecto.Schema
  import Ecto.Changeset

  types = %{
      afk: 1,
  }

  @spec type(atom()) :: pos_integer()
  def type(event_type)

  for {type, value} <- types do
    def type(unquote(type)), do: unquote(value)
  end

  def type(_event_type), do: 1

  schema "afk_events" do
    field :started_at, :utc_datetime
    field :ended_at, :utc_datetime
    field :message, :string
    field :event_type, :integer
    belongs_to :user, MaldnessBot.Models.User
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:message, :started_at, :ended_at])
    |> validate_required([:message])
  end

  @spec close(pos_integer()) :: :ok
  def close(event_id) do
    MaldnessBot.Repo.get!(__MODULE__, event_id)
    |> changeset(%{ended_at: DateTime.utc_now() |> DateTime.truncate(:second)})
    |> MaldnessBot.Repo.update!()
  end
end
