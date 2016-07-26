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
      game = %{
        "width" => "20",
        "height" => "20",
      }

      conn = post conn, game_path(conn, :create), game: game

      {:atomic, id} = :mnesia.transaction fn ->
        :mnesia.last(Game)
      end

      assert redirected_to(conn, 302) == game_path(conn, :show, id)
    end
  end
end
