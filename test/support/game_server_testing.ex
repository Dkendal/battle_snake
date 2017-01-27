defmodule BattleSnake.GameServerTesting do
  def teardown do
    :ok = Supervisor.terminate_child(
      BattleSnake.Supervisor,
      BattleSnake.GameServer.Supervisor)

    {:ok, _} = Supervisor.restart_child(
      BattleSnake.Supervisor,
      BattleSnake.GameServer.Supervisor)
  end

  def flush(c \\ :ok) do
    receive do
      _ ->
        flush()
    after 0 ->
        c
    end
  end
end
