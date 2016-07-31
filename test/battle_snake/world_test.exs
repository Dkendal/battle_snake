defmodule BattleSnake.WorldTest do
  alias BattleSnake.{World, Point, Snake}
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

    test "sets no food if set to 0", %{world: world} do
      world = put_in world.max_food, 0
      world = World.init_food(world)
      assert length(world.food) == 0
    end
  end

  describe "#clean_up_dead" do
    test "removes any snakes that die in head to heads", %{world: world} do
      snake = %Snake{coords: [%Point{y: 5, x: 5}]}
      snake = %Snake{coords: [%Point{y: 5, x: 5}]}

      world = put_in world.snakes, [snake, snake]

      world = World.clean_up_dead(world)
      assert world.snakes == []
      assert world.dead_snakes == [snake, snake]
    end

    test "removes any snakes that die this turn", %{world: world} do
      snake = %Snake{coords: [%Point{y: 10, x: 10}]}
      world = put_in world.snakes, [snake]

      world = World.clean_up_dead(world)
      assert world.snakes == []
      assert world.dead_snakes == [snake]
    end
  end
end
