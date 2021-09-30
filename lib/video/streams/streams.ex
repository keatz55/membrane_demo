defmodule Video.Streams do
  @moduledoc """
  The Streams context.
  """
  alias Video.{Repo, Streams.Stream}
  alias Phoenix.PubSub
  alias Scrivener.Page

  import Ecto.Query, warn: false

  @namespace "streams"

  def subscribe, do: PubSub.subscribe(Video.PubSub, @namespace)
  def subscribe(id), do: PubSub.subscribe(Video.PubSub, "#{@namespace}:#{id}")

  @doc """
  Returns the list of streams.

  ## Examples

      iex> list(params)
      [%Stream{}, ...]

  """
  def list(params \\ %{}) do
    page = Map.get(params, :pg) || Map.get(params, "pg") || 1
    page_size = Map.get(params, :per_pg) || Map.get(params, "per_pg") || 10
    sort = Map.get(params, :sort) || Map.get(params, "sort")

    {
      :ok,
      Stream.init_query()
      |> Stream.filter(params)
      |> group_by([stream: s], s.id)
      |> Stream.sort(sort)
      |> Repo.paginate(page: page, page_size: page_size)
      |> virtual_fields()
    }
  end

  @doc """
  Gets a single stream.

  ## Examples

      iex> get(123)
      {:ok, %Stream{}}

      iex> get(456)
      {:error, :not_found}

  """
  def get(params) do
    Stream.init_query()
    |> Stream.filter(params)
    |> group_by([stream: s], s.id)
    |> Repo.one()
    |> case do
      nil -> {:error, :not_found}
      stream -> {:ok, stream}
    end
    |> virtual_fields()
  end

  @doc """
  Creates a stream.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Stream{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    %Stream{}
    |> Stream.changeset(attrs)
    |> Repo.insert()
    |> preloads()
    |> virtual_fields()
    |> notify_subscribers(:stream_created)
  end

  @doc """
  Updates a stream.

  ## Examples

      iex> update(stream, %{field: new_value})
      {:ok, %Stream{}}

      iex> update(stream, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%Stream{} = stream, attrs) do
    stream
    |> Stream.changeset(attrs)
    |> Repo.update()
    |> preloads()
    |> virtual_fields()
    |> notify_subscribers(:stream_updated)
  end

  @doc """
  Deletes a stream.

  ## Examples

      iex> delete(stream)
      {:ok, %Stream{}}

      iex> delete(stream)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Stream{} = stream) do
    stream
    |> Repo.delete()
    |> notify_subscribers(:stream_deleted)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking stream changes.

  ## Examples

      iex> change(stream)
      %Ecto.Changeset{data: %Stream{}}

  """
  def change(%Stream{} = stream, attrs \\ %{}) do
    Stream.changeset(stream, attrs)
  end

  ### Private/Utility Functions ######

  defp preloads({:ok, stream}), do: {:ok, stream}
  defp preloads({:error, reason}), do: {:error, reason}

  defp notify_subscribers({:ok, stream}, event) do
    PubSub.broadcast(Video.PubSub, @namespace, {event, stream})
    PubSub.broadcast(Video.PubSub, "#{@namespace}:#{stream.id}", {event, stream})

    {:ok, stream}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}

  defp virtual_fields(%Page{entries: entries} = page) do
    %Page{page | entries: entries}
  end

  defp virtual_fields({:ok, stream}), do: {:ok, stream}
  defp virtual_fields({:error, reason}), do: {:error, reason}
end
