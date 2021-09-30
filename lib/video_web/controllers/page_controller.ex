defmodule VideoWeb.PageController do
  use VideoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
