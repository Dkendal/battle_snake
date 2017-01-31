defmodule BattleSnake.GameServer.SupervisorTest do
  alias BattleSnake.{
    GameServer,
  }

  use BattleSnake.Case, async: false

  @sup_name GameServer.Supervisor

  describe "GameServer.Supervisor.start_game_server/1" do
    import GameServer.Supervisor, only: [start_game_server: 1]

    test "does not link the GameServer to the calling process" do
      {:ok, game_server} = start_game_server([%GameServer.State{}])
      assert not self() in (game_server |> Process.info() |> Keyword.get(:links))
    end

    test "starts a game server process" do
      {:ok, game_server} = start_game_server([%GameServer.State{}])
      assert is_pid game_server
      assert %{active: 1, workers: 1} = Supervisor.count_children(@sup_name)
    end

    test "does not restart processes that have died" do
      {:ok, game_server} = start_game_server([%GameServer.State{}])
      GenServer.stop(game_server, :normal)
      ref = Process.monitor(game_server)
      assert_receive {:DOWN, ^ref, _, _, _}
      assert %{active: 0} = Supervisor.count_children(@sup_name)
    end
  end
end
