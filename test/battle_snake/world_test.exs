defmodule BattleSnake.WorldTest do
  alias BattleSnake.{World, Point, Snake}
  use ExUnit.Case, async: true
  use Property

  setup context do
    world = %World{
      max_food: 4,
      height: 10,
      width: 10,
    }
    Map.put context, :world, world
  end

  describe "#rand_unoccupied_space" do
    property "in the bounds of the board, on an unoccupied space" do
      forall world(), fn w ->
        point = World.rand_unoccupied_space(w)

        coords = Enum.flat_map w.snakes, &(&1.coords)

        ( not point in w.food and
          not point in coords and
          point.x in World.cols(w) and
          point.y in World.rows(w))
      end
    end
  end

  describe "#stock_food" do
    test "sets food on the board, up to a max", %{world: world} do
      world = World.stock_food(world)
      assert length(world.food) == 4
    end

    test "sets no food if set to 0", %{world: world} do
      world = put_in world.max_food, 0
      world = World.stock_food(world)
      assert length(world.food) == 0
    end

    test "adds to existing stocks", %{world: world} do
      food = %Point{y: 5, x: 5}
      world = put_in world.food, [food]
      world = put_in world.max_food, 2

      world = World.stock_food(world)

      assert([
        %Point{},
        ^food
      ] = world.food)
    end
  end

  describe "#clean_up_dead" do
    test "removes any snakes that die in head to heads", %{world: world} do
      snake = %Snake{coords: [%Point{y: 5, x: 5}]}

      world = put_in world.snakes, [snake, snake]

      world = World.clean_up_dead(world)
      assert world.snakes == []
      assert world.dead_snakes == [snake, snake]
    end

    test "removes snakes that died in body collisions", %{world: world} do
      snake = %Snake{coords: [%Point{y: 5, x: 5}, %Point{y: 5, x: 5}]}
      world = put_in world.snakes, [snake]

      world = World.clean_up_dead(world)
      assert world.snakes == []
      assert world.dead_snakes == [snake]
    end

    test "removes any snakes that die this turn", %{world: world} do
      snake = %Snake{coords: [%Point{y: 10, x: 10}]}
      world = put_in world.snakes, [snake]

      world = World.clean_up_dead(world)
      assert world.snakes == []
      assert world.dead_snakes == [snake]
    end
  end

  describe "#tick" do
    test "eating food" do
      world = %World{
        width: 10,
        height: 10,
        max_food: 1,
        food: [
          %Point{x: 0, y: 0},
        ],
        snakes: [
          %Snake{
            name: "Snake",
            coords: [
              %Point{x: 0, y: 1},
              %Point{x: 1, y: 1},
            ]
          }
        ]
      }

      moves = %{"Snake" => "up"}

      world = World.tick(world, moves)

      assert([
        %Snake{
          name: "Snake",
          coords: [
            %Point{x: 0, y: 0},
            %Point{x: 0, y: 1},
            %Point{x: 0, y: 1},
          ]
        }
      ]
      == world.snakes)
    end
  end
end
