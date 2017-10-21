defmodule BsWeb.TestControllerTest do
  use BsWeb.ConnCase

  test "GET index" do
    conn = build_conn()
    conn = get(conn, test_path(conn, :index))
    assert html_response(conn, 200)
  end
end
