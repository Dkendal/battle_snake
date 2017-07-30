defmodule BattleSnakeWeb.SkinControllerTest do
  alias BattleSnakeWeb.GameForm
  use BattleSnakeWeb.ConnCase

  describe "GET show" do
    test "it is OK", %{conn: conn} do
      game = %GameForm{id: "sup"}

      Mnesia.Repo.save game

      conn = get conn, skin_path(conn, :show, game)

      assert html_response(conn, 200)
    end
  end
end
