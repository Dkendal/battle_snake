defmodule PoisonTest do
  alias BattleSnake.{World, Point, Snake, Board}

  use ExUnit.Case, async: true

  describe "BattleSnake.World" do
    test "encode" do
      head = %{
        "state" => "head",
        "snake" => "bar",
      }

      body = %{
        "state" => "body",
        "snake" => "bar",
      }

      #   0 1
      # 0   h
      # 1 f b
      world = %World{
        turn: 0,
        food: [
          %Point{x: 0, y: 1},
        ],
        snakes: [
          %Snake{
            coords: [
              %Point{x: 1, y: 0},
              %Point{x: 1, y: 1},
            ],
            name: "bar",
            url: "example.com",
          }
        ],
        height: 2,
        width: 2,
      }

      actual = cast! world

      expected = %{
        "board" => [
          [Board.empty, Board.food],
          [head, body],
        ],
        "food" => [[0,1]],
        "snakes" => [
          %{
            "name" => "bar",
            "coords" => [[1,0],[1,1]],
            "url" => "example.com",
          }
        ],
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
