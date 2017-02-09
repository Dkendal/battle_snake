defmodule BattleSnake.GameServerTesting do
  def teardown do
    ref = Process.monitor(BattleSnake.GameServer.Supervisor)

    :ok = Supervisor.terminate_child(
      BattleSnake.Supervisor,
      BattleSnake.GameServer.Supervisor)

    receive do
      {:DOWN, ^ref, _, _, _} ->
        :ok
    after 100 ->
        raise "Killing BattleSnake.Supervisor failed"
    end

    Supervisor.restart_child(
      BattleSnake.Supervisor,
      BattleSnake.GameServer.Supervisor)

    :ok
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
