defmodule VideoWeb.TrackLive.Index do
  use VideoWeb, :live_view

  alias Video.Tracks
  alias Video.Tracks.Track

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page, list_tracks())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    {:ok, track} = Tracks.get(%{id: id})

    socket
    |> assign(:page_title, "Edit Track")
    |> assign(:track, track)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Track")
    |> assign(:track, %Track{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tracks")
    |> assign(:track, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, track} = Tracks.get(%{id: id})
    {:ok, _} = Tracks.delete(track)

    {:noreply, assign(socket, :page, list_tracks())}
  end

  defp list_tracks do
    {:ok, page} = Tracks.list()
    page
  end
end
