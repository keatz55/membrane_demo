defmodule VideoWeb.TrackLive.Show do
  use VideoWeb, :live_view

  alias Video.Tracks

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:ok, track} = Tracks.get(%{id: id})

    {:noreply,
     assign(socket,
       page_title: page_title(socket.assigns.live_action),
       srtp_key: Application.get_env(:video, :srtp_key),
       track: track
     )}
  end

  defp page_title(:show), do: "Show Track"
  defp page_title(:edit), do: "Edit Track"
end
