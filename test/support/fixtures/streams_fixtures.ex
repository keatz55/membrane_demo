defmodule Video.StreamsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Video.Streams` context.
  """

  @doc """
  Generate a stream.
  """
  def stream_fixture(attrs \\ %{}) do
    {:ok, stream} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Video.Streams.create_stream()

    stream
  end
end
