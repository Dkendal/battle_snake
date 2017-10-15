defmodule Bs.GameServerTest do
  alias Bs.Game
  alias Bs.Game.Registry

  use Bs.Case, async: false

  setup do
    mock(BsRepo)
    mock(HTTPoison)

    expect(BsRepo, :get!, fn BsRepo.GameForm, 1 ->
      build(:game_form, id: "1")
    end)

    on_exit(&unload/0)
  end

  test "#find starts new servers" do
    # assert {:ok, pid} =  Game.find("1")
  end

  test "#find returns running game servers" do
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

  test "#restart" do
    {:ok, pid, _} = Game.ensure_started("1")

    ref = Process.monitor(pid)

    Game.restart("1")

    assert_receive {:DOWN, ^ref, _, ^pid, :normal}

    assert [{pid2, _}] = Registry.lookup("1")

    assert pid != pid2
  end
end
