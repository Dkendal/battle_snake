defmodule BattleSnake.Api.GameControllerTest do
  use BattleSnake.ConnCase

  describe "GET index" do
    test "lists all games", %{conn: conn} do
      conn = get conn, game_path(conn, :index)
      assert body = html_response(conn, 200)
      assert body == "{}"
    end
  end
end
