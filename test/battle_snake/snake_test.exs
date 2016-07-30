defmodule BattleSnake.SnakeTest do
  alias BattleSnake.{World, Snake, Point}

  use ExUnit.Case, async: true

  describe "#dead?" do
    test "detects body collisions" do
      world = %World{width: 10, height: 10}
      coords = [
        %Point{y: 10, x: 5},
        %Point{y: 10, x: 5}
      ]
      snake = %Snake{coords: coords}
      world = %{world | snakes: [snake]}

      assert Snake.dead?(snake, world) == true
    end

    test "detects wall collisions" do
      world = %World{width: 10, height: 10}
      snake = %Snake{coords: [%Point{y: 10, x: 5}]}
      world = %{world | snakes: [snake]}

      assert Snake.dead?(snake, world) == true

      snake = %{snake | coords: [%Point{y: 5, x: 10}]}
      world = %{world | snakes: [snake]}

      assert Snake.dead?(snake, world) == true

      snake = %{snake | coords: [%Point{y: 0, x: 5}]}
      world = %{world | snakes: [snake]}

      assert Snake.dead?(snake, world) == true

      snake = %{snake | coords: [%Point{y: 5, x: 0}]}
      world = %{world | snakes: [snake]}

      assert Snake.dead?(snake, world) == true

      snake = %{snake | coords: [%Point{y: 5, x: 5}]}
      world = %{world | snakes: [snake]}

      assert Snake.dead?(snake, world) == false
    end
  end

  describe "#len" do
    test "returns the length of the snake" do
      snake = %Snake{coords: [0, 0, 0]}
      assert Snake.len(snake) == 3
    end
  end

  describe "#grow" do
    test "increases the length of the snake" do
      snake = %Snake{coords: [0]}
      snake = Snake.grow(snake, 4)
      assert Snake.len(snake) == 5
    end
  end

  describe "#resolve_head_to_head" do
    test "kills both snakes in the event of a tie" do
      snakes = [
        %Snake{coords: [%Point{y: 5, x: 5}, %Point{y: 5, x: 4},]},
        %Snake{coords: [%Point{y: 5, x: 5}, %Point{y: 4, x: 5},]},
      ]

      assert Snake.resolve_head_to_head(snakes) == []
    end

    test "kills the smaller snakes, and grows the victor" do
      snakes = [
        %Snake{coords: [%Point{y: 5, x: 5}, %Point{y: 5, x: 4},]},
        %Snake{coords: [%Point{y: 5, x: 5}, %Point{y: 4, x: 5}, %Point{y: 3, x: 5},]},
      ]

      assert(Snake.resolve_head_to_head(snakes) == [
        %Snake{
          coords: [
            %Point{y: 5, x: 5},
            %Point{y: 4, x: 5},
            %Point{y: 3, x: 5},
            %Point{y: 3, x: 5}
          ]
        }
      ])
    end

    test "does nothing to nonoverlapping snakes" do
      snakes = [
        %Snake{coords: [%Point{y: 5, x: 5}, %Point{y: 5, x: 4}]},
        %Snake{coords: [%Point{y: 5, x: 5}, %Point{y: 4, x: 5}]},
        %Snake{coords: [%Point{y: 6, x: 6}, %Point{y: 6, x: 7}]},
      ]

      assert(Snake.resolve_head_to_head(snakes) == [
        %Snake{coords: [%Point{y: 6, x: 6}, %Point{y: 6, x: 7}]}
      ])
    end
  end
end
