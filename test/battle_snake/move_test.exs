defmodule BattleSnake.MoveTest  do
  use ExUnit.Case, async: true
  use Property
  alias BattleSnake.{Snake, Move}

  describe "BattleSnake.Move.all/1" do
    test "returns a default move when the request times-out" do
      move_fn = fn _snake ->
        Process.sleep 100
        %Move{move: "left"}
      end

      snakes = [%Snake{}]

      assert(match?([%Move{move: "up"}],
            Move.all(snakes, move_fn, 0)))
    end

    test "returns a move for each snake" do
      move_fn = fn _snake ->
        %Move{move: "left"}
      end

      snakes = [%Snake{}]

      assert(match?([%Move{move: "left"}],
            Move.all(snakes, move_fn)))
    end
  end
end
