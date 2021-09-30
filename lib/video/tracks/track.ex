defmodule Video.Tracks.Track do
  alias Video.Streams.Stream

  use Video.Schema

  @optional []
  @required [:type]

  schema "tracks" do
    field(:ssrc, :integer)
    field(:type, Ecto.Enum, values: [:audio, :video])

    belongs_to(:stream, Stream)

    timestamps()
  end

  @doc false
  def changeset(track, attrs) do
    track
    |> cast(attrs, @optional ++ @required)
    |> validate_required(@required)
  end

  def init_query do
    base_query()
    |> join(:left, [track: t], assoc(t, :stream), as: :stream)
    |> preload([stream: s], stream: s)
  end
end
