defmodule BattleSnake.WorldMovementTest do
  use ExUnit.Case, async: true
  alias BattleSnake.{
    World,
    WorldMovement,
    Snake,
    Move,
    Point}

  @green_snake %Snake{
    name: "green-snake",
    coords: [
      %Point{x: 0, y: 0}
    ]
  }

  @snake_key Snake.Access.key(@green_snake)

  @up %Move{
    move: "up",
    snake_key: @snake_key
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
      assert %{@snake_key => @up} == @apply.moves
    end

    test "updates snake coordinates" do
      assert(@apply.snakes == [
        %Snake{
          name: "green-snake",
          coords: [%Point{x: 0, y: -1}]}])
    end
  end
end
