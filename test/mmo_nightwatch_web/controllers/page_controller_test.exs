defmodule MmoNightwatchWeb.PageControllerTest do
  use MmoNightwatchWeb.ConnCase

  test "GET /game", %{conn: conn} do
    conn = get(conn, "/game")
    assert html_response(conn, 200)
  end
end
