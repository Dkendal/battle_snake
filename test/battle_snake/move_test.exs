defmodule BattleSnake.MoveTest  do
  use ExUnit.Case, async: true
  alias BattleSnake.{Snake, Move, World}

  @green_snake %Snake{name: :green}

  @world %World{
    snakes: [@green_snake]
  }

  @up %Move{move: "up", snake: @green_snake}

  @left %Move{move: "left", snake: @green_snake}

  def up_fn(%Snake{}, %World{}) do
    {:ok, %Move{move: "left"}}
  end

  def sleep_fn(%Snake{}, %World{}) do
    Process.sleep 100
    {:ok, @left}
  end

  def error_fn(%Snake{}, %World{}) do
    {:error, "msg"}
  end

  describe "BattleSnake.Move.all/1" do
    test "returns a default move when the request encounters an error" do
      expected = put_in @up.response_state, {:error, "msg"}

      assert(match?([^expected],
            Move.all(@world, &error_fn/2)))
    end

    test "returns a default move when the request times-out" do
      expected = put_in @up.response_state, :timeout

      assert(match?([^expected],
            Move.all(@world, &sleep_fn/2, 0)))
    end

    test "returns a move for each snake" do
      expected = put_in @left.response_state, :ok

      assert(match?([^expected],
            Move.all(@world, &up_fn/2)))
    end
  end
end
