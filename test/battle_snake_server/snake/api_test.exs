defmodule BattleSnakeServer.Snake.ApiTest do
  alias BattleSnake.{World, Move}
  alias BattleSnakeServer.Game
  alias BattleSnakeServer.Snake.Api

  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup do
    Api.start

    snake_form = %BattleSnakeServer.Snake{url: "localhost:4000"}

    snake = %BattleSnake.Snake{
      url: "localhost:4000",
      color: "#6699ff",
      head_url: "",
      name: "Snek",
      taunt: "gotta go fast",
    }

    game = %Game{id: "sup", width: 20, height: 20}

    world = %World{
      width: 10,
      height: 10,
      snakes: [
        %{snake| coords: [[0,0]]}
      ]
    }

    %{
      game: game,
      snake: snake,
      snake_form: snake_form,
      world: world,
    }
  end

  test "#load", %{game: game, snake: snake, snake_form: snake_form} do
    use_cassette "snake start" do
      assert Api.load(snake_form, game) == snake
    end
  end

  test "#move", %{world: world, snake: snake} do
    use_cassette "snake move" do
      actual = Api.move(snake, world)
      assert actual == %Move{move: "down", taunt: "down"}
    end
  end
end
