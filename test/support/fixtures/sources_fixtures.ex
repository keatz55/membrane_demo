defmodule Video.SourcesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Video.Sources` context.
  """

  @doc """
  Generate a source.
  """
  def source_fixture(attrs \\ %{}) do
    {:ok, source} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Video.Sources.create_source()

    source
  end
end
