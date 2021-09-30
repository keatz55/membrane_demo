defmodule VideoWeb.StreamLive.Index do
  use VideoWeb, :live_view

  alias Video.Streams
  alias Video.Streams.Stream

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page, list_streams())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    {:ok, stream} = Streams.get(%{id: id})

    socket
    |> assign(:page_title, "Edit Stream")
    |> assign(:stream, stream)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Stream")
    |> assign(:stream, %Stream{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Streams")
    |> assign(:stream, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, stream} = Streams.get(%{id: id})
    {:ok, _} = Streams.delete(stream)

    {:noreply, assign(socket, :page, list_streams())}
  end

  defp list_streams do
    {:ok, page} = Streams.list()
    page
  end
end
