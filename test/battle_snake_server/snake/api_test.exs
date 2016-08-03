defmodule BattleSnakeServer.Snake.ApiTest do
  alias BattleSnakeServer.Game
  alias BattleSnakeServer.Snake.Api

  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup do
    Api.start

    snake = %BattleSnakeServer.Snake{url: "localhost:4000"}
    game = %Game{id: "sup", width: 20, height: 20}

    %{snake: snake, game: game}
  end

  test "#load", %{game: game, snake: snake} do
    use_cassette "snake start" do
      snake = Api.load(snake, game)

      %BattleSnake.Snake{
        color: "#6699ff",
        head_url: "",
        name: "Snek",
        taunt: "gotta go fast",
      } = snake
    end
  end
end
