defmodule BattleSnake.Game.SupervisorTest do
  alias BattleSnake.Game.Supervisor

  use BattleSnake.Case, async: false

  describe "Supervisor.start_game_server/1" do
    test "starts a game server process" do
      {:ok, game_server} = Supervisor.start_game_server([build(:state)])
      assert is_pid game_server
    end
  end
end
