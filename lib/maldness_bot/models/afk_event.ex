defmodule MaldnessBot.Models.AfkEvent do
  use Ecto.Schema
  import Ecto.Changeset
  import MaldnessBot.Gettext

  types = %{
    afk: {1, "%{user} went afk: %{message}", "%{user} arrived and said: %{message}"},
    sleep: {2, "%{user} went sleeping: %{message}", "%{user} woke up and said: %{message}"},
    work: {3, "%{user} went working: %{message}", "%{user} done working and said: %{message}"}
  }

  schema "afk_events" do
    field(:started_at, :utc_datetime)
    field(:ended_at, :utc_datetime)
    field(:message, :string)
    field(:event_type, :integer)
    belongs_to(:user, MaldnessBot.Models.User)
  end

  @spec type(atom()) :: pos_integer()
  def type(event_type)

  @spec format_message(%__MODULE__{}, :in | :out, map()) :: String.t()
  def format_message(event, direction, user)

  for {type, {value, in_afk, out_afk}} <- types do
    def type(unquote(type)), do: unquote(value)

    def format_message(%__MODULE__{event_type: unquote(value)} = event, :in, user),
      do:
        gettext(unquote(in_afk), %{
          message: event.message,
          user: MaldnessBot.Helpers.format_user(user)
        })

    def format_message(%__MODULE__{event_type: unquote(value)} = event, :out, user),
      do:
        gettext(unquote(out_afk), %{
          message: event.message,
          user: MaldnessBot.Helpers.format_user(user)
        })
  end

  def type(_event_type), do: 1

  def changeset(struct, params) do
    struct
    |> cast(params, [:message, :started_at, :ended_at])
    |> validate_required([:message])
  end

  @spec close(pos_integer()) :: %__MODULE__{}
  def close(event_id) do
    MaldnessBot.Repo.get!(__MODULE__, event_id)
    |> changeset(%{ended_at: DateTime.utc_now() |> DateTime.truncate(:second)})
    |> MaldnessBot.Repo.update!()
  end
end
