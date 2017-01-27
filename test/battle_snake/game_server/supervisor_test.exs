defmodule BattleSnake.GameServer.SupervisorTest do
  use BattleSnake.Case, async: false

  @sup_name BattleSnake.GameServer.Supervisor

  describe "BattleSnake.GameServer.Supervisor.start_game_server/1" do
    import BattleSnake.GameServer.Supervisor, only: [start_game_server: 1]

    test "starts a game server process" do
      {:ok, game_server} = start_game_server([%BattleSnake.GameServer.State{}])
      assert is_pid game_server
      assert %{active: 1, workers: 1} = Supervisor.count_children(@sup_name)
    end

    test "does not restart processes that have died" do
      {:ok, game_server} = start_game_server([%BattleSnake.GameServer.State{}])
      GenServer.stop(game_server, :normal)
      ref = Process.monitor(game_server)
      assert_receive {:DOWN, ^ref, _, _, _}
      assert %{active: 0} = Supervisor.count_children(@sup_name)
    end
  end
end
