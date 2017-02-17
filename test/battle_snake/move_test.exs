defmodule BattleSnake.MoveTest  do
  use BattleSnake.Case, async: true

  alias BattleSnake.{
    Move,
    Point,
  }

  describe "Move.to_point/1" do
    test "converts direction strings to Points" do
      assert %Point{x: 0, y: -1} ==
        %Move{move: "up"} |> Move.to_point
    end
  end
end
