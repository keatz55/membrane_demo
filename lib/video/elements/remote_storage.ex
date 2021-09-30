defmodule Video.Elements.RemoteStorage do
  @moduledoc """
  `Video.Elements.RemoteStorage` implementation that saves the stream to
  files remotely.
  """
  @behaviour Membrane.HTTPAdaptiveStream.Storage

  @enforce_keys [:directory]
  defstruct @enforce_keys

  @type t :: %__MODULE__{directory: Path.t()}

  @impl true
  def init(%__MODULE__{} = config), do: config

  @impl true
  def store(name, contents, %{mode: :binary}, %__MODULE__{directory: location}) do
    # res =

    "uploads"
    |> ExAws.S3.put_object(Path.join(location, name), contents)
    |> ExAws.request()

    # if String.contains?(location, "lts") do
    #   IO.inspect(name, label: "BINARY NAME")
    #   IO.inspect(byte_size(contents), label: "BINARY SIZE")
    #   IO.inspect(contents, label: "BINARY CONTENTS")
    #   IO.inspect(res, label: "BINARY RESPONSE")
    # end

    :ok

    # contents
    # |> S3.Upload.stream_file()
    # |> S3.upload("uploads", Path.join(location, name))
    # |> ExAws.request()

    # contents
    # |> S3.Upload.stream_file()
    # |> S3.upload("uploads", Path.join(location, name))
    # |> ExAws.request()

    # File.write(Path.join(location, name), contents, [:binary])
  end

  @impl true
  def store(_name, _contents, %{mode: :text}, %__MODULE__{directory: _location}) do
    # IO.inspect(name, label: "TEXT NAME")
    # IO.inspect(contents, label: "TEXT CONTENTS")

    # "uploads"
    # |> ExAws.S3.put_object(Path.join(location, name), contents)
    # |> ExAws.request()

    :ok

    # File.write(Path.join(location, name), contents)
  end

  @impl true
  def remove(_name, _ctx, %__MODULE__{directory: _location}) do
    # File.rm(Path.join(location, name))
    :ok
  end
end
