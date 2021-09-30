defmodule VideoWeb.StreamView do
  use VideoWeb, :view
  alias VideoWeb.StreamView

  def render("index.json", %{streams: streams}) do
    %{data: render_many(streams, StreamView, "stream.json")}
  end

  def render("show.json", %{stream: stream}) do
    %{data: render_one(stream, StreamView, "stream.json")}
  end

  def render("stream.json", %{stream: stream}) do
    %{
      id: stream.id,
      name: stream.name
    }
  end
end
