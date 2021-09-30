defmodule Video.Streams.Stream do
  alias Video.Tracks.Track

  use Video.Schema

  @optional []
  @required [:name, :type]

  schema "streams" do
    field(:name, :string)
    field(:type, Ecto.Enum, values: [:srtp])

    has_many(:tracks, Track)

    timestamps()
  end

  @doc false
  def changeset(stream, attrs) do
    stream
    |> cast(attrs, @optional ++ @required)
    |> validate_required(@required)
  end

  def init_query do
    base_query()
    |> join(:left, [stream: s], assoc(s, :tracks), as: :track)
    |> preload([:tracks])
  end
end
