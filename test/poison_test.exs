defmodule PoisonTest do
  use ExUnit.Case, async: true

  describe "BattleSnake.World" do
    alias BattleSnake.{World, Point}

    test "is encoded" do
      world = %BattleSnake.World{
        turn: 0,
        food: [],
        snakes: [],
      }

      actual = world
      |> Poison.encode!
      |> Poison.decode!

      expected = %{
        "board" => [],
        "food" => [],
        "snakes" => [],
        "turn" => 0,
      }

      assert expected == actual
    end
  end
end
