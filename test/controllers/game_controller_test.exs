defmodule BattleSnakeServer.GameControllerTest do
  use BattleSnakeServer.ConnCase

  alias BattleSnakeServer.Game

  describe "GET index" do
    test "lists all entries on index", %{conn: conn} do
      conn = get conn, game_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing games"
    end
  end

  describe "POST create" do
    test "does the thing", %{conn: conn} do
      game = %{}

      conn = post conn, game_path(conn, :create), game: game

      assert redirected_to(conn, 302) == game_path(conn, :show, 1)
    end
  end
end
