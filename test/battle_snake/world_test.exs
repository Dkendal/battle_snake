defmodule BattleSnake.WorldTest do
  alias BattleSnake.{World, Point}
  use ExUnit.Case, async: true

  setup context do
    world = %World{
      max_food: 4,
      height: 10,
      width: 10,
    }
    Map.put context, :world, world
  end

  describe "#rand_unoccupied_space" do
    test "returns a Point with nothing in it", %{world: world} do
      point = World.rand_unoccupied_space(world)
      assert %Point{} = point
    end
  end

  describe "#init_food" do
    test "sets food on the board, up to a max", %{world: world} do
      world = World.init_food(world)
      assert length(world.food) == 4
    end
  end
end
