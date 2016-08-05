defmodule BattleSnake.GameServerTest do
  alias BattleSnake.GameServer
  alias BattleSnake.World

  use ExUnit.Case, async: true

  setup do
    world = %World{}
    opts = [delay: 0]
    f = phone_home(self)

    {:ok, pid} = GameServer.start_link({world, f, opts})

    %{pid: pid}
  end

  describe ".resume_game" do
    test "returns the world", %{pid: pid} do
      %World{} = GameServer.resume_game(pid)
    end

    test "calls the tick function repeatably", %{pid: pid} do
      start(pid)
      assert_receive {:turn, 1}, 100
      assert_receive {:turn, 2}, 100
    end
  end

  describe ".pause_game" do
    test "stops the tick function from being called" do
      world = %World{}
      opts = [delay: 0]
      f = self_destruct(self)

      {:ok, pid} = GameServer.start_link({world, f, opts})

      GameServer.resume_game(pid)

      assert_receive {:tick, 1}, 100
      refute_receive {:tick, _}, 100

      GameServer.resume_game(pid)

      assert_receive {:tick, 2}, 100
      refute_receive _, 100
    end
  end

  describe ".stop_game" do
  end

  def start(pid) do
    GameServer.resume_game(pid)
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
        GameServer.pause_game(this)
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
