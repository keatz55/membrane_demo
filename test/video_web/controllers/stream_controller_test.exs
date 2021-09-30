defmodule VideoWeb.StreamControllerTest do
  use VideoWeb.ConnCase

  import Video.StreamsFixtures

  alias Video.Streams.Stream

  @create_attrs %{
    name: "some name"
  }
  @update_attrs %{
    name: "some updated name"
  }
  @invalid_attrs %{name: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all streams", %{conn: conn} do
      conn = get(conn, Routes.stream_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create stream" do
    test "renders stream when data is valid", %{conn: conn} do
      conn = post(conn, Routes.stream_path(conn, :create), stream: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.stream_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.stream_path(conn, :create), stream: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update stream" do
    setup [:create_stream]

    test "renders stream when data is valid", %{conn: conn, stream: %Stream{id: id} = stream} do
      conn = put(conn, Routes.stream_path(conn, :update, stream), stream: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.stream_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, stream: stream} do
      conn = put(conn, Routes.stream_path(conn, :update, stream), stream: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete stream" do
    setup [:create_stream]

    test "deletes chosen stream", %{conn: conn, stream: stream} do
      conn = delete(conn, Routes.stream_path(conn, :delete, stream))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.stream_path(conn, :show, stream))
      end
    end
  end

  defp create_stream(_) do
    stream = stream_fixture()
    %{stream: stream}
  end
end
