defmodule VideoWeb.StreamController do
  use VideoWeb, :controller

  alias Video.Streams
  alias Video.Streams.Stream

  action_fallback VideoWeb.FallbackController

  def index(conn, _params) do
    streams = Streams.list_streams()
    render(conn, "index.json", streams: streams)
  end

  def create(conn, %{"stream" => stream_params}) do
    with {:ok, %Stream{} = stream} <- Streams.create_stream(stream_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.stream_path(conn, :show, stream))
      |> render("show.json", stream: stream)
    end
  end

  def show(conn, %{"id" => id}) do
    stream = Streams.get_stream!(id)
    render(conn, "show.json", stream: stream)
  end

  def update(conn, %{"id" => id, "stream" => stream_params}) do
    stream = Streams.get_stream!(id)

    with {:ok, %Stream{} = stream} <- Streams.update_stream(stream, stream_params) do
      render(conn, "show.json", stream: stream)
    end
  end

  def delete(conn, %{"id" => id}) do
    stream = Streams.get_stream!(id)

    with {:ok, %Stream{}} <- Streams.delete_stream(stream) do
      send_resp(conn, :no_content, "")
    end
  end
end
