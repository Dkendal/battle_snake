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

  describe ".start_game" do
    test "returns the world", %{pid: pid} do
      %World{} = GameServer.start_game(pid)
    end

    test "calls the tick function repeatably", %{pid: pid} do
      start(pid)
      assert_receive {:turn, 1}, 100
      assert_receive {:turn, 2}, 100
    end
  end

  describe ".pause_game" do
  end

  describe ".stop_game" do
  end

  def start(pid) do
    GameServer.start_game(pid)
  end
end
