defmodule BattleSnakeServer.GameControllerTest do
  use BattleSnakeServer.ConnCase

  alias BattleSnakeServer.Game

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, game_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing games"
  end
end
