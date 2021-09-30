defmodule Video.Tracks do
  @moduledoc """
  The Tracks context.
  """
  alias Video.{Repo, Tracks.Track}
  alias Phoenix.PubSub
  alias Scrivener.Page

  import Ecto.Query, warn: false

  @namespace "tracks"

  def subscribe, do: PubSub.subscribe(Video.PubSub, @namespace)
  def subscribe(id), do: PubSub.subscribe(Video.PubSub, "#{@namespace}:#{id}")

  @doc """
  Returns the list of tracks.

  ## Examples

      iex> list(params)
      [%Track{}, ...]

  """
  def list(params \\ %{}) do
    page = Map.get(params, :pg) || Map.get(params, "pg") || 1
    page_size = Map.get(params, :per_pg) || Map.get(params, "per_pg") || 10
    sort = Map.get(params, :sort) || Map.get(params, "sort")

    {
      :ok,
      Track.init_query()
      |> Track.filter(params)
      |> Track.sort(sort)
      |> Repo.paginate(page: page, page_size: page_size)
      |> virtual_fields()
    }
  end

  @doc """
  Gets a single track.

  ## Examples

      iex> get(123)
      {:ok, %Track{}}

      iex> get(456)
      {:error, :not_found}

  """
  def get(params) do
    Track.init_query()
    |> Track.filter(params)
    |> Repo.one()
    |> case do
      nil -> {:error, :not_found}
      track -> {:ok, track}
    end
    |> virtual_fields()
  end

  @doc """
  Creates a track.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Track{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    %Track{}
    |> Track.changeset(attrs)
    |> Repo.insert()
    |> preloads()
    |> virtual_fields()
    |> notify_subscribers(:track_created)
  end

  @doc """
  Updates a track.

  ## Examples

      iex> update(track, %{field: new_value})
      {:ok, %Track{}}

      iex> update(track, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%Track{} = track, attrs) do
    track
    |> Track.changeset(attrs)
    |> Repo.update()
    |> preloads()
    |> virtual_fields()
    |> notify_subscribers(:track_updated)
  end

  @doc """
  Deletes a track.

  ## Examples

      iex> delete(track)
      {:ok, %Track{}}

      iex> delete(track)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Track{} = track) do
    track
    |> Repo.delete()
    |> notify_subscribers(:track_deleted)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking track changes.

  ## Examples

      iex> change(track)
      %Ecto.Changeset{data: %Track{}}

  """
  def change(%Track{} = track, attrs \\ %{}) do
    Track.changeset(track, attrs)
  end

  ### Private/Utility Functions ######

  defp preloads({:ok, track}), do: {:ok, track}
  defp preloads({:error, reason}), do: {:error, reason}

  defp notify_subscribers({:ok, track}, event) do
    PubSub.broadcast(Video.PubSub, @namespace, {event, track})
    PubSub.broadcast(Video.PubSub, "#{@namespace}:#{track.id}", {event, track})

    {:ok, track}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}

  defp virtual_fields(%Page{entries: entries} = page) do
    %Page{page | entries: entries}
  end

  defp virtual_fields({:ok, track}), do: {:ok, track}
  defp virtual_fields({:error, reason}), do: {:error, reason}
end
