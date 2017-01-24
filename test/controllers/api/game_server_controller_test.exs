defmodule BattleSnake.Api.GameServerControllerTest do
  alias BattleSnake.{
    GameForm,
    SnakeForm,
  }

  use BattleSnake.ConnCase, async: false

  describe "POST create" do
    test "creates a new GameForm", %{conn: conn} do
      post conn, api_game_server_path(conn, :create), %{"id" => "1"}
    end
  end
end
