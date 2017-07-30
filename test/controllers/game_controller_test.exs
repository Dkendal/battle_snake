defmodule BattleSnakeWeb.GameControllerTest do
  use BattleSnakeWeb.ConnCase

  alias BattleSnakeWeb.GameForm

  describe "GET index" do
    test "lists all entries on index", %{conn: conn} do
      conn = get conn, game_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing games"
    end
  end

  describe "POST create" do
    test "does the thing", %{conn: conn} do
      game_form = %{
        "width" => "100",
        "height" => "100",
      }

      conn = post conn, game_path(conn, :create), game_form: game_form


      id = :mnesia.activity :transaction, fn ->
        :mnesia.last(GameForm)
      end

      assert redirected_to(conn, 302) == game_path(conn, :edit, id)

      [game] = :mnesia.activity :transaction, fn ->
        Mnesia.Repo.load(:mnesia.read(GameForm, id))
      end

      assert %GameForm{width: 100, height: 100,} = game
    end
  end
end
