defmodule Video.TracksTest do
  use Video.DataCase

  alias Video.Tracks

  describe "tracks" do
    alias Video.Tracks.Track

    import Video.TracksFixtures

    @invalid_attrs %{name: nil}

    test "list_tracks/0 returns all tracks" do
      track = track_fixture()
      assert Tracks.list_tracks() == [track]
    end

    test "get_track!/1 returns the track with given id" do
      track = track_fixture()
      assert Tracks.get_track!(track.id) == track
    end

    test "create_track/1 with valid data creates a track" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Track{} = track} = Tracks.create_track(valid_attrs)
      assert track.name == "some name"
    end

    test "create_track/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tracks.create_track(@invalid_attrs)
    end

    test "update_track/2 with valid data updates the track" do
      track = track_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Track{} = track} = Tracks.update_track(track, update_attrs)
      assert track.name == "some updated name"
    end

    test "update_track/2 with invalid data returns error changeset" do
      track = track_fixture()
      assert {:error, %Ecto.Changeset{}} = Tracks.update_track(track, @invalid_attrs)
      assert track == Tracks.get_track!(track.id)
    end

    test "delete_track/1 deletes the track" do
      track = track_fixture()
      assert {:ok, %Track{}} = Tracks.delete_track(track)
      assert_raise Ecto.NoResultsError, fn -> Tracks.get_track!(track.id) end
    end

    test "change_track/1 returns a track changeset" do
      track = track_fixture()
      assert %Ecto.Changeset{} = Tracks.change_track(track)
    end
  end
end
