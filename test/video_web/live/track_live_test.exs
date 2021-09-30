defmodule VideoWeb.TrackLiveTest do
  use VideoWeb.ConnCase

  import Phoenix.LiveViewTest
  import Video.TracksFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_track(_) do
    track = track_fixture()
    %{track: track}
  end

  describe "Index" do
    setup [:create_track]

    test "lists all tracks", %{conn: conn, track: track} do
      {:ok, _index_live, html} = live(conn, Routes.track_index_path(conn, :index))

      assert html =~ "Listing Tracks"
      assert html =~ track.name
    end

    test "saves new track", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.track_index_path(conn, :index))

      assert index_live |> element("a", "New Track") |> render_click() =~
               "New Track"

      assert_patch(index_live, Routes.track_index_path(conn, :new))

      assert index_live
             |> form("#track-form", track: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#track-form", track: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.track_index_path(conn, :index))

      assert html =~ "Track created successfully"
      assert html =~ "some name"
    end

    test "updates track in listing", %{conn: conn, track: track} do
      {:ok, index_live, _html} = live(conn, Routes.track_index_path(conn, :index))

      assert index_live |> element("#track-#{track.id} a", "Edit") |> render_click() =~
               "Edit Track"

      assert_patch(index_live, Routes.track_index_path(conn, :edit, track))

      assert index_live
             |> form("#track-form", track: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#track-form", track: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.track_index_path(conn, :index))

      assert html =~ "Track updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes track in listing", %{conn: conn, track: track} do
      {:ok, index_live, _html} = live(conn, Routes.track_index_path(conn, :index))

      assert index_live |> element("#track-#{track.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#track-#{track.id}")
    end
  end

  describe "Show" do
    setup [:create_track]

    test "displays track", %{conn: conn, track: track} do
      {:ok, _show_live, html} = live(conn, Routes.track_show_path(conn, :show, track))

      assert html =~ "Show Track"
      assert html =~ track.name
    end

    test "updates track within modal", %{conn: conn, track: track} do
      {:ok, show_live, _html} = live(conn, Routes.track_show_path(conn, :show, track))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Track"

      assert_patch(show_live, Routes.track_show_path(conn, :edit, track))

      assert show_live
             |> form("#track-form", track: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#track-form", track: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.track_show_path(conn, :show, track))

      assert html =~ "Track updated successfully"
      assert html =~ "some updated name"
    end
  end
end
