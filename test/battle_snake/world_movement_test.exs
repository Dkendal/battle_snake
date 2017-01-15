defmodule BattleSnake.WorldMovementTest do
  use ExUnit.Case, async: true
  alias BattleSnake.{
    World,
    WorldMovement,
    Snake,
    Move,
    Point}

  setup do
    green_snake = %Snake{
      name: :green,
      coords: [
        %Point{x: 0, y: 0}
      ]
    }

    moves = [
      %Move{
        move: "up",
        snake: green_snake
      }
    ]

    world = %World{
      snakes: [
        green_snake
      ]
    }

    {:ok,
     moves: moves,
     world: world}
  end

  describe "WorldMovement.apply/2" do
    test "updates snake coordinates", %{world: world, moves: moves} do
      new_world = WorldMovement.apply(world, moves)

      assert(new_world.snakes == [
        %Snake{
          name: :green,
          coords: [%Point{x: 0, y: -1}]}])
    end
  end
end
