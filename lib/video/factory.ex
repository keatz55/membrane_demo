defmodule Video.Factory do
  @moduledoc """
  Factory for generating data
  """
  alias Video.{Streams.Stream, Tracks.Track}

  use ExMachina.Ecto, repo: Video.Repo

  def stream_factory do
    %Stream{
      name: sequence(:stream_name, &"Camera ##{&1 + 1}"),
      tracks: [build(:track, type: :audio), build(:track, type: :video)],
      type: :srtp
    }
  end

  def track_factory do
    %Track{
      type: :video
    }
  end
end
