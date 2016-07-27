defmodule BattleSnakeServer.PlayControllerTest do
  alias BattleSnakeServer.{Game}
  use BattleSnakeServer.ConnCase

  describe "GET show" do
    test "it is OK" do
      game = %Game{id: "sup"}

      conn = get conn, play_path(conn, :show, game)
      assert html_response(conn, 200)
    end
  end
end
