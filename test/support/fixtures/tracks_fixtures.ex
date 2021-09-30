defmodule Video.TracksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Video.Tracks` context.
  """

  @doc """
  Generate a track.
  """
  def track_fixture(attrs \\ %{}) do
    {:ok, track} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Video.Tracks.create_track()

    track
  end
end
