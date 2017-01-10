defmodule BattleSnakeServer.PlayControllerTest do
  alias BattleSnakeServer.{GameForm}
  use BattleSnakeServer.ConnCase

  describe "GET show" do
    test "it is OK", %{conn: conn} do
      game = %GameForm{id: "sup"}

      GameForm.save game

      conn = get conn, play_path(conn, :show, game)

      assert html_response(conn, 200)
    end
  end
end
