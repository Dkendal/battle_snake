defmodule BattleSnake.MoveTest  do
  use ExUnit.Case, async: true
  use Property
  alias BattleSnake.{Snake, Move}

  @green_snake %Snake{name: :green}
  @up %Move{move: "up", snake: @green_snake}
  @left %Move{move: "left", snake: @green_snake}

  describe "BattleSnake.Move.all/1" do
    test "returns a default move when the request times-out" do
      move_fn = fn _snake ->
        Process.sleep 100
        @left
      end

      snakes = [@green_snake]

      assert(match?([@up],
            Move.all(snakes, move_fn, 0)))
    end

    test "returns a default move if the task dies" do
      move_fn = fn _snake ->
        Process.exit(self(), :kill)
      end

      snakes = [@green_snake]

      assert(match?([@up],
            Move.all(snakes, move_fn, 0)))
    end

    test "returns a move for each snake" do
      move_fn = fn _snake ->
        %Move{move: "left"}
      end

      snakes = [@green_snake]

      assert(match?([@left],
            Move.all(snakes, move_fn)))
    end
  end
end
