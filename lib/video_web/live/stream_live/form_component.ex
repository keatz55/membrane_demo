defmodule VideoWeb.StreamLive.FormComponent do
  use VideoWeb, :live_component

  alias Video.Streams

  @impl true
  def update(%{stream: stream} = assigns, socket) do
    changeset = Streams.change(stream)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"stream" => stream_params}, socket) do
    changeset =
      socket.assigns.stream
      |> Streams.change(stream_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"stream" => stream_params}, socket) do
    save_stream(socket, socket.assigns.action, stream_params)
  end

  defp save_stream(socket, :edit, stream_params) do
    case Streams.update(socket.assigns.stream, stream_params) do
      {:ok, _stream} ->
        {:noreply,
         socket
         |> put_flash(:info, "Stream updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_stream(socket, :new, stream_params) do
    case Streams.create(stream_params) do
      {:ok, _stream} ->
        {:noreply,
         socket
         |> put_flash(:info, "Stream created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
