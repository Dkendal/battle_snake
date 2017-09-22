defmodule BsWeb.Test.SnakeTestControllerTest do
  use BsWeb.ConnCase

  describe "index" do
    test "lists all snake_test", %{conn: conn} do
      conn = get conn, test_snake_test_path(conn, :index)
      assert html_response(conn, 200)
    end
  end
end
