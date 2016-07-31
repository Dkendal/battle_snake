defmodule PoisonTest do
  alias BattleSnake.{World, Point}

  use ExUnit.Case, async: true

  describe "BattleSnake.World" do

    test "is encoded" do
      world = %World{
        turn: 0,
        food: [],
        snakes: [],
      }

      actual = cast! world

      expected = %{
        "board" => [],
        "food" => [],
        "snakes" => [],
        "turn" => 0,
      }

      assert expected == actual
    end
  end

  describe "BattleSnake.Point" do
    test "encoding" do
      point = %Point{x: 1, y: 2}
      expected = [1, 2]

      actual = cast! point

      assert expected == expected
    end
  end

  def cast!(s) do
    s
    |> Poison.encode!
    |> Poison.decode!
  end
end
