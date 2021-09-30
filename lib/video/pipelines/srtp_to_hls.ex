defmodule Video.Pipelines.SrtpToHls do
  @moduledoc """
  Pipeline for ingesting and converting SRTP packets to HLS output.

  Tracking Matrix:
    - stream
    - track
    - storage_type | segment_duration | target_duration
  """
  alias Video.{Tracks, Tracks.Track}

  require Logger

  use Membrane.Pipeline

  @dynamic_audio_pt 127
  @dynamic_video_pt 96

  @segment_duration_long 60
  @segment_duration_short 4

  @allowed [@dynamic_audio_pt, @dynamic_video_pt]

  defmodule State do
    @moduledoc false
    defstruct hls_elements: nil, port: nil, tracks: nil
  end

  @impl true
  def handle_init(port) do
    srtp_key = Application.get_env(:video, :srtp_key)

    children = %{
      app_source: %Membrane.Element.UDP.Source{
        local_port_no: port,
        recv_buffer_size: 500_000
      },
      rtp: %Membrane.RTP.SessionBin{
        secure?: true,
        srtp_policies: [
          %ExLibSRTP.Policy{
            ssrc: :any_inbound,
            key: srtp_key
          }
        ]
      }
    }

    links = [
      link(:app_source)
      |> via_in(Pad.ref(:rtp_input, make_ref()), buffer: [fail_size: 300])
      |> to(:rtp)
    ]

    spec = %ParentSpec{children: children, links: links}
    {{:ok, spec: spec}, %State{hls_elements: %{}, port: port, tracks: %{}}}
  end

  @impl true
  def handle_notification({:new_rtp_stream, ssrc, pt}, :rtp, _ctx, state) when pt in @allowed do
    type = get_pt_type(pt)

    with {:ok, track} <- Tracks.get(%{ssrc: ssrc, type: type}) do
      IO.inspect(ssrc, label: "New #{track.type} ssrc")

      children = generate_track_children(track, state)
      links = generate_track_links(track)
      spec = %ParentSpec{children: children, links: links}

      tracks = Map.put(state.tracks, track.ssrc, track)
      hls_elements = Map.put(state.hls_elements, track.stream.id, track.stream)

      {{:ok, spec: spec}, %State{state | hls_elements: hls_elements, tracks: tracks}}
    else
      {:error, :not_found} -> {:ok, state}
    end
  end

  def handle_notification(notification, _element, _ctx, state) do
    IO.inspect(notification, label: "NOTIFICATION")
    {:ok, state}
  end

  defp get_pt_type(@dynamic_audio_pt), do: :audio
  defp get_pt_type(@dynamic_video_pt), do: :video
  defp get_pt_type(_pt), do: :unkown

  defp generate_track_children(%Track{type: :audio} = track, state) do
    children = [
      {{:audio_payloader, track.ssrc}, Membrane.MP4.Payloader.AAC},
      {{:audio_tee, track.ssrc}, Membrane.Element.Tee.Master},
      {{:audio_cmaf_muxer, "#{track.ssrc}_long"},
       %Membrane.MP4.CMAF.Muxer{
         segment_duration: Membrane.Time.seconds(@segment_duration_long)
       }},
      {{:audio_cmaf_muxer, "#{track.ssrc}_short"},
       %Membrane.MP4.CMAF.Muxer{
         segment_duration: Membrane.Time.seconds(@segment_duration_short)
       }}
    ]

    if !hls_track_element_setup?(track, state) do
      [generate_hls_track_element(track, "long"), generate_hls_track_element(track, "short")] ++
        children
    else
      children
    end
  end

  defp generate_track_children(%Track{type: :video} = track, state) do
    children = [
      {
        {:video_nal_parser, track.ssrc},
        %Membrane.H264.FFmpeg.Parser{
          framerate: {30, 1},
          alignment: :au,
          attach_nalus?: true
        }
      },
      {{:video_payloader, track.ssrc}, Membrane.MP4.Payloader.H264},
      {{:video_tee, track.ssrc}, Membrane.Element.Tee.Master},
      {{:video_cmaf_muxer, "#{track.ssrc}_long"},
       %Membrane.MP4.CMAF.Muxer{
         segment_duration: Membrane.Time.seconds(@segment_duration_long)
       }},
      {{:video_cmaf_muxer, "#{track.ssrc}_short"},
       %Membrane.MP4.CMAF.Muxer{
         segment_duration: Membrane.Time.seconds(@segment_duration_short)
       }}
    ]

    if !hls_track_element_setup?(track, state) do
      [generate_hls_track_element(track, "long"), generate_hls_track_element(track, "short")] ++
        children
    else
      children
    end
  end

  defp generate_track_links(%Track{type: :audio} = track) do
    [
      # Input
      link(:rtp)
      |> via_out(Pad.ref(:output, track.ssrc))
      |> to({:audio_payloader, track.ssrc})
      |> to({:audio_tee, track.ssrc}),
      # Long Output
      link({:audio_tee, track.ssrc})
      |> via_out(:copy)
      |> to({:audio_cmaf_muxer, "#{track.ssrc}_long"})
      |> via_in(Pad.ref(:input, "#{track.ssrc}_long"))
      |> to({:hls, "#{track.stream.id}_long"}),
      # Short Output
      link({:audio_tee, track.ssrc})
      |> via_out(:master)
      |> to({:audio_cmaf_muxer, "#{track.ssrc}_short"})
      |> via_in(Pad.ref(:input, "#{track.ssrc}_short"))
      |> to({:hls, "#{track.stream.id}_short"})
    ]
  end

  defp generate_track_links(%Track{type: :video} = track) do
    [
      # Input
      link(:rtp)
      |> via_out(Pad.ref(:output, track.ssrc))
      |> to({:video_nal_parser, track.ssrc})
      |> to({:video_payloader, track.ssrc})
      |> to({:video_tee, track.ssrc}),
      # Long Output
      link({:video_tee, track.ssrc})
      |> via_out(:copy)
      |> to({:video_cmaf_muxer, "#{track.ssrc}_long"})
      |> via_in(Pad.ref(:input, "#{track.ssrc}_long"))
      |> to({:hls, "#{track.stream.id}_long"}),
      # Short Output
      link({:video_tee, track.ssrc})
      |> via_out(:master)
      |> to({:video_cmaf_muxer, "#{track.ssrc}_short"})
      |> via_in(Pad.ref(:input, "#{track.ssrc}_short"))
      |> to({:hls, "#{track.stream.id}_short"})
    ]
  end

  defp hls_track_element_setup?(%Track{} = track, %State{} = state) do
    Map.has_key?(state.hls_elements, track.stream.id)
  end

  defp generate_hls_track_element(track, storage_type) do
    directory = "output/#{track.stream.id}/#{storage_type}"
    # directory = "#{storage_type}/#{track.stream.id}"
    File.rm_rf(directory)
    File.mkdir_p(directory)

    {{:hls, "#{track.stream.id}_#{storage_type}"},
     %Membrane.HTTPAdaptiveStream.Sink{
       manifest_module: Membrane.HTTPAdaptiveStream.HLS,
       storage: %Membrane.HTTPAdaptiveStream.Storages.FileStorage{directory: directory},
       # storage: %Video.Elements.RemoteStorage{directory: directory},
       target_window_duration: target_window_duration(storage_type)
     }}
  end

  defp target_window_duration("long"), do: Membrane.Time.seconds(@segment_duration_long * 12)
  defp target_window_duration("short"), do: Membrane.Time.seconds(@segment_duration_short * 12)
end
