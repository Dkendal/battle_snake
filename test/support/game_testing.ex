defmodule Bs.GameServerTesting do
  def teardown do
    ref = Process.monitor(Bs.Game.Supervisor)

    :ok = Supervisor.terminate_child(
      Bs.Supervisor,
      Bs.Game.Supervisor)

    receive do
      {:DOWN, ^ref, _, _, _} ->
        :ok
    after 100 ->
        raise "Killing Bs.Supervisor failed"
    end

    Supervisor.restart_child(
      Bs.Supervisor,
      Bs.Game.Supervisor)

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
