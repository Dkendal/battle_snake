defmodule BattleSnake.GameServerTest do
  alias BattleSnake.GameServer
  alias BattleSnake.World

  use ExUnit.Case, async: true

  setup do
    world = %World{}

    this = self

    f = fn world ->
      world = update_in world.turn, & &1+1
      send this, {:turn, world.turn}
      world
    end

    opts = [delay: 0]

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
    end
  end

  describe ".stop_game" do
  end

  def start(pid) do
    GameServer.resume_game(pid)
  end
end
