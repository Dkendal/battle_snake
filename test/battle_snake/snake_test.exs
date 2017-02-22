defmodule BattleSnake.SnakeTest do
  alias BattleSnake.{
    World,
    Snake,
    Point
  }

  use BattleSnake.Case, async: true
  use Property
  use Point
  import Point

  @world %World{width: 10, height: 10}

  property "inside the bounds of the board" do
    forall({range(0, 9), range(0, 9)}, fn {x, y} ->
      snake = %Snake{coords: [%Point{x: x, y: y}]}

      Snake.dead?(snake, @world) == false
    end)
  end

  property "wall collision" do
    xs = suchthat(integer(), & not &1 in 0..9)

    forall({xs, xs}, fn {x, y} ->
      snake = %Snake{coords: [%Point{x: x, y: y}]}

      Snake.dead?(snake, @world) == true
    end)
  end

  describe "Snake.dead?" do
    test "detects body collisions" do
      world = %World{width: 10, height: 10}
      coords = [
        %Point{y: 5, x: 5},
        %Point{y: 5, x: 5}
      ]
      snake = %Snake{coords: coords}
      world = %{world | snakes: [snake]}

      assert Snake.dead?(snake, world) == true
    end

    test "detects wall collisions" do
      world = %World{width: 10, height: 10}
      snake = %Snake{coords: [%Point{y: 10, x: 5}]}
      world = %{world | snakes: [snake]}

      assert Snake.dead?(snake, world) == true

      snake = %{snake | coords: [%Point{y: 5, x: 10}]}
      world = %{world | snakes: [snake]}

      assert Snake.dead?(snake, world) == true

      snake = %{snake | coords: [%Point{y: -1, x: 5}]}
      world = %{world | snakes: [snake]}

      assert Snake.dead?(snake, world) == true

      snake = %{snake | coords: [%Point{y: 5, x: -1}]}
      world = %{world | snakes: [snake]}

      assert Snake.dead?(snake, world) == true

      snake = %{snake | coords: [%Point{y: 5, x: 5}]}
      world = %{world | snakes: [snake]}

      assert Snake.dead?(snake, world) == false
    end

    test "detects starvation" do
      world = build(:world)
      snake = build(:snake)

      [snake: snake, world: world] =
        with_snake_in_world(snake: snake, world: world, length: 1)

      refute Snake.dead?(snake, world)

      snake = snake |> with_starvation()

      assert Snake.dead?(snake, world)
    end
  end

  describe "#len" do
    test "returns the length of the snake" do
      snake = %Snake{coords: [0, 0, 0]}
      assert Snake.len(snake) == 3
    end
  end

  describe "#grow" do
    test "increases the length of the snake" do
      snake = %Snake{coords: [0]}
      snake = Snake.grow(snake, 4)
      assert Snake.len(snake) == 5
    end
  end

  describe "#resolve_head_to_head" do
    test "kills both snakes in the event of a tie" do
      snakes = [
        %Snake{coords: [%Point{y: 5, x: 5}, %Point{y: 5, x: 4},]},
        %Snake{coords: [%Point{y: 5, x: 5}, %Point{y: 4, x: 5},]},
      ]

      assert Snake.resolve_head_to_head(snakes) == []
    end

    test "kills smaller snakes" do
      small_snake = build(:snake, id: :small, coords: [p(0, 0)])
      big_snake = build(:snake, id: :big, coords: [p(0, 0), p(1, 0)])

      snakes = [small_snake, big_snake]

      assert(Snake.resolve_head_to_head(snakes) == [big_snake])
    end

    test "does nothing to nonoverlapping snakes" do
      snakes = [
        %Snake{coords: [%Point{y: 5, x: 5}, %Point{y: 5, x: 4}]},
        %Snake{coords: [%Point{y: 5, x: 5}, %Point{y: 4, x: 5}]},
        %Snake{coords: [%Point{y: 6, x: 6}, %Point{y: 6, x: 7}]},
      ]

      assert(Snake.resolve_head_to_head(snakes) == [
        %Snake{coords: [%Point{y: 6, x: 6}, %Point{y: 6, x: 7}]}
      ])
    end
  end

  describe "#move" do
    test "moves a snake in the direction" do
      coords = [
        %Point{y: 5, x: 5},
        %Point{y: 4, x: 5},
      ]

      snake = %Snake{coords: coords}
      move = %Point{y: 1, x: 0}

      assert(Snake.move(snake, move) == %Snake{
        coords: [
          %Point{y: 6, x: 5},
          %Point{y: 5, x: 5},
        ]
      })
    end
  end

  describe "Poison.Encoder.encode(BattleSnake.Snake, [])" do
    test "formats as JSON" do
      snake = %Snake{
        coords: [%Point{x: 0, y: 1}],
        name: "snake",
        url: "example.com",
        id: "1",
        taunt: "",
        health_points: 100,
        color: "red",
        head_url: "head.example.com",
      }

      expected = %{
        "name" => "snake",
        "coords" => [[0, 1]],
        "health_points" => 100,
        "taunt" => "",
        "id" => "1",
        "head_url" => "head.example.com",
        "color" => "red",
      }

      actual = PoisonTesting.cast!(snake)

      assert expected == actual
    end
  end
end
