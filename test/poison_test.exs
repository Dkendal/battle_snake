defmodule PoisonTest do
  alias BattleSnake.{World, Point, Snake}

  use ExUnit.Case, async: true

  describe "BattleSnake.World" do
    test "encode" do
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

      assert expected == actual
    end
  end

  describe "BattleSnake.Snake" do
    test "encoding" do
      snake = %Snake{
        coords: [%Point{x: 0, y: 1}],
        name: "snake",
        url: "example.com"
      }

      expected = %{
        "name" => "snake",
        "coords" => [[0, 1]],
        "url" => "example.com",
      }

      actual = cast! snake

      assert expected == actual
    end
  end

  def cast!(s) do
    s
    |> Poison.encode!
    |> Poison.decode!
  end
end
