defmodule MmoNightwatchWeb.PageController do
  use MmoNightwatchWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
