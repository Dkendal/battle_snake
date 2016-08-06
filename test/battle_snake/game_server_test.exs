defmodule BattleSnake.GameServerTest do
  alias BattleSnake.GameServer
  alias BattleSnake.World

  use ExUnit.Case, async: true

  setup do
    world = %World{}
    objective = fn _ -> false end
    opts = [delay: 0, objective: objective]
    f = phone_home(self)

    {:ok, pid} = GameServer.start_link({world, f, opts})

    %{pid: pid}
  end

  describe ".resume" do
    test "returns the world", %{pid: pid} do
      assert :ok = GameServer.resume(pid)
    end

    test "calls the tick function repeatably", %{pid: pid} do
      start(pid)
      assert_receive {:turn, 1}, 100
      assert_receive {:turn, 2}, 100
    end
  end

  describe ".pause" do
    test "stops the tick function from being called" do
      world = %World{}
      objective = fn _ -> false end
      opts = [delay: 0, objective: objective]
      f = self_destruct(self)

      {:ok, pid} = GameServer.start_link({world, f, opts})

      :ok = GameServer.resume(pid)

      assert_receive {:tick, 1}, 100
      refute_receive {:tick, _}, 100

      :ok = GameServer.resume(pid)

      assert_receive {:tick, 2}, 100
      refute_receive _, 100
    end
  end

  describe ".stop_game" do
  end

  def start(pid) do
    GameServer.resume(pid)
  end

  def self_destruct(pid) do
    # will get spammed by this
    tick = fn world ->
      send pid, {:tick, world.turn}
    end

    # pause the game after first tick
    fn world ->
      world = update_in world.turn, & &1+1

      tick.(world)

      this = self

      spawn_link fn ->
        GameServer.pause(this)
      end

      world
    end
  end

  def phone_home(pid) do
    fn world ->
      world = update_in world.turn, & &1+1
      send pid, {:turn, world.turn}

      world
    end
  end
end
