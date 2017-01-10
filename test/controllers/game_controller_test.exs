defmodule BattleSnakeServer.GameControllerTest do
  use BattleSnakeServer.ConnCase

  alias BattleSnakeServer.GameForm

  describe "GET index" do
    test "lists all entries on index", %{conn: conn} do
      conn = get conn, game_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing games"
    end
  end

  describe "POST create" do
    test "does the thing", %{conn: conn} do
      game = %{
        "width" => "100",
        "height" => "100",
      }

      :mnesia.transaction fn ->
        conn = post conn, game_path(conn, :create), game: game

        {:atomic, game} = GameForm.last

        assert redirected_to(conn, 302) == game_path(conn, :edit, game)

        assert(%GameForm{
          width: 100,
          height: 100,
        } = game)
      end
    end
  end
end
