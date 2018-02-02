defmodule Bs.GameTest do
  alias Bs.Game
  alias Bs.Game.Registry

  use Bs.Case, async: false

  setup do
    insert(:game_form, id: 1)
    :ok
  end

  test "#resume calls resume on the gen server" do
    spawn_link(fn ->
      Registry.register("1", nil)
      assert_receive {_, from, :resume}
      GenServer.reply(from, :ok)
    end)

    assert :ok = Game.resume("1")
  end

  test "#resume starts the process if it doesn't exist" do
    assert [] == Registry.lookup("1")
    assert :ok = Game.resume("1")

    assert [{pid, _}] = Registry.lookup("1")
    assert :ok = Game.resume("1")

    assert [{^pid, _}] = Registry.lookup("1")
  end

  test "#prev calls the gen server" do
    spawn_link(fn ->
      Registry.register("1", nil)
      assert_receive {_, from, :prev}
      GenServer.reply(from, :ok)
    end)

    assert :ok = Game.prev("1")
  end

  test "#stop" do
    {:ok, pid, _} = Game.ensure_started("1")

    ref = Process.monitor(pid)

    Game.stop("1")

    assert_receive {:DOWN, ^ref, _, ^pid, :normal}
  end

  @tag :skip
  test "#restart" do
    {:ok, pid, _} = Game.ensure_started("1")

    ref = Process.monitor(pid)

    Game.restart("1")

    assert_receive {:DOWN, ^ref, _, ^pid, :normal}

    assert [{pid2, _}] = Registry.lookup("1")

    assert pid != pid2
  end
end
