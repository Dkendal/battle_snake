defmodule BattleSnake.MoveTest  do
  use ExUnit.Case, async: true
  use Property
  alias BattleSnake.{Snake, Move, World}

  @green_snake %Snake{name: :green}

  @world %World{
    snakes: [@green_snake]
  }

  @up %Move{move: "up", snake: @green_snake}
  @left %Move{move: "left", snake: @green_snake}

  def up_fn(_snake, _world) do
    %Move{move: "left"}
  end

  def sleep_fn(_snake, _world) do
    Process.sleep 100
    @left
  end

  describe "BattleSnake.Move.all/1" do
    test "returns a default move when the request times-out" do

      snakes = [@green_snake]

      assert(match?([@up],
            Move.all(@world, &sleep_fn/2, 0)))
    end

    test "returns a move for each snake" do
      snakes = [@green_snake]

      assert(match?([@left],
            Move.all(@world, &up_fn/2)))
    end
  end
end
