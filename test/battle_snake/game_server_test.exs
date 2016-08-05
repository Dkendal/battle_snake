defmodule BattleSnake.GameServerTest do
  alias BattleSnake.GameServer
  alias BattleSnake.World

  use ExUnit.Case, async: true

  setup do
    world = %World{}
    {:ok, pid} = GameServer.start_link(world)
    %{pid: pid}
  end

  describe ".start_game" do
    test "starts the game", %{pid: pid} do
      %World{} = GameServer.start_game(pid)
    end
  end

  describe ".pause_game" do
  end

  describe ".stop_game" do
  end
end
