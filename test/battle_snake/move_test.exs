defmodule BattleSnake.MoveTest  do
  use ExUnit.Case, async: true
  use Property
  alias BattleSnake.{Snake, Move}

  describe "BattleSnake.Move.all/1" do
    test "returns a move for each snake" do
      move_fn = fn _snake ->
        %Move{move: "up"}
      end

      snakes = [%Snake{}]

      assert match?([%Move{}], Move.all(snakes, move_fn))
    end
  end
end
