defmodule Bs.MoveTest do
  use Bs.Case, async: true
  use Bs.Point

  alias Bs.{Move, Point}

  describe "Move.to_point/1" do
    test "converts direction strings to Points" do
      assert %Point{x: 0, y: -1} == %Move{move: "up"} |> Move.to_point()
    end
  end

  describe "Move.default_move(snake) when the last move is undefined" do
    test "goes up" do
      s1 = build(:snake, coords: [p(0, 0), p(0, 0)])
      s2 = build(:snake, coords: [p(0, 0), p(10, 10)])
      s3 = build(:snake, coords: [])

      for snake <- [s1, s2, s3] do
        move = Move.default_move(snake)
        assert move == %Move{move: "up"}
      end
    end
  end

  describe "Move.default_move(snake)" do
    test "repeats the previous move" do
      snake = build(:snake, coords: [p(5, 5), p(6, 5), p(7, 5)])
      move = Move.default_move(snake)
      assert move == %Move{move: "left"}
      new_snake = Bs.Snake.move(snake, move)
      assert new_snake.coords == [p(4, 5), p(5, 5), p(6, 5)]
    end
  end
end
