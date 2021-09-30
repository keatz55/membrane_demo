defmodule VideoWeb.StreamLive.Show do
  alias Video.{Streams, Tracks.Track}

  use VideoWeb, :live_view

  @impl true
  def render(assigns) do
    ~L"""
    <h1>Show Stream</h1>

    <%= if @live_action in [:edit] do %>
      <%= live_modal VideoWeb.StreamLive.FormComponent,
        id: @stream.id,
        title: @page_title,
        action: @live_action,
        stream: @stream,
        return_to: Routes.stream_show_path(@socket, :show, @stream) %>
    <% end %>

    <ul>
      <li>
        <strong>ID:</strong>
        <%= @stream.id %>
      </li>
      <li>
        <strong>Name:</strong>
        <%= @stream.name %>
      </li>
      <li>
        <strong>Type:</strong>
        <%= @stream.type %>
      </li>
    </ul>

    <h2>Tracks:</h2>
    <table>
      <thead>
        <tr>
          <th>Type</th>
          <th>SSRC</th>
        </tr>
      </thead>
      <tbody id="streams">
        <%= for track <- @stream.tracks do %>
          <tr id={"track-#{track.id}"}>
            <td><%= track.type %></td>
            <td><%= track.ssrc %></td>
          </tr>
        <% end %>
      </tbody>
    </table>

    <h2>Gstreamer Command:</h2>
    <pre
      id="<%= @stream.id %>_gstreamer_cmd"
      phx-hook="Copy"
      style="cursor:pointer;"
    ><%= raw(@gstreamer_cmd) %></pre>

    <span><%= live_patch "Edit", to: Routes.stream_show_path(@socket, :edit, @stream), class: "button" %></span> |
    <span><%= live_redirect "Back", to: Routes.stream_index_path(@socket, :index) %></span>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:ok, stream} = Streams.get(%{id: id})

    {:noreply,
     assign(socket,
       gstreamer_cmd: build_gstreamer_cmd(stream),
       page_title: page_title(socket.assigns.live_action),
       srtp_key: Application.get_env(:video, :srtp_key),
       stream: stream
     )}
  end

  defp page_title(:show), do: "Show Stream"
  defp page_title(:edit), do: "Edit Stream"

  defp build_gstreamer_cmd(stream) do
    "gst-launch-1.0 -v #{Enum.map(stream.tracks, &gstreamer_track/1)}"
  end

  defp gstreamer_track(%Track{ssrc: ssrc, type: :audio}) do
    """
      \\
      audiotestsrc \\
      ! audio/x-raw,rate=44100 \\
      ! faac \\
      ! rtpmp4gpay pt=127 ssrc=#{ssrc} \\
      ! srtpenc key=\"#{Base.encode16(srtp_key())}\" \\
        rtp-cipher=\"aes-128-icm\" rtp-auth=\"hmac-sha1-80\" \\
        rtcp-cipher=\"aes-128-icm\" rtcp-auth=\"hmac-sha1-80\" \\
      ! udpsink host=127.0.0.1 port=5000 \\
    """
  end

  defp gstreamer_track(%Track{ssrc: ssrc, type: :video}) do
    """
      videotestsrc \\
      ! video/x-raw,format=I420 \\
      ! x264enc key-int-max=10 tune=zerolatency \\
      ! rtph264pay pt=96 ssrc=#{ssrc} \\
      ! srtpenc key=\"#{Base.encode16(srtp_key())}\" \\
        rtp-cipher=\"aes-128-icm\" rtp-auth=\"hmac-sha1-80\" \\
        rtcp-cipher=\"aes-128-icm\" rtcp-auth=\"hmac-sha1-80\" \\
      ! udpsink host=127.0.0.1 port=5000
    """
  end

  defp srtp_key, do: Application.get_env(:video, :srtp_key)
end
