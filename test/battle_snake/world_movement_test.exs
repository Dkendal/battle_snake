defmodule BattleSnake.WorldMovementTest do
  use BattleSnake.Case, async: true
  alias BattleSnake.{
    World,
    WorldMovement,
    Snake,
    Move,
    Point}

  @green_snake %Snake{
    id: 1,
    name: "green-snake",
    coords: [
      %Point{x: 0, y: 0}
    ]
  }

  @up %Move{
    move: "up",
    snake_id: 1
  }

  @moves [@up]

  @world %World{
    snakes: [
      @green_snake
    ]
  }

  describe "WorldMovement.next/1" do
    @next WorldMovement.next(@world)

    test "returns a world struct" do
      assert match? %World{}, @next
    end
  end

  describe "WorldMovement.apply/2" do
    @apply WorldMovement.apply(@world, @moves)

    test "returns a world struct" do
      assert %World{} = @apply
    end

    test "sets world.moves" do
      assert %{1 => @up} == @apply.moves
    end

    test "updates snake coordinates" do
      assert(@apply.snakes == [
        %Snake{
          id: 1,
          name: "green-snake",
          taunt: nil,
          coords: [%Point{x: 0, y: -1}]}])
    end
  end
end
