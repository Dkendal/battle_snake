defmodule BattleSnake.SnakeTest do
  alias BattleSnake.{World, Snake, Point}

  use ExUnit.Case, async: true

  describe "#dead?" do
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
end
