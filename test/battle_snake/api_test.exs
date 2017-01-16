defmodule BattleSnake.ApiTest do
  alias BattleSnake.{Snake, Board, Point, Move}

  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @snake_form %BattleSnake.SnakeForm{
    url: "http://example.snake"
  }

  @game_form %BattleSnake.GameForm{
  }

  @snake %BattleSnake.Snake{
    url: "http://example.snake",
    coords: [%Point{x: 0, y: 0}]
  }

  @world %BattleSnake.World{
    snakes: [@snake]
  }

  describe "BattleSnake.Api.load/3" do
    test "on success produces a snake" do
      body = %{
        name: "example-snake",
        color: "#123123"
      }

      mock = fn (:post, "http://example.snake/start", _, _, _) ->
        {:ok, %HTTPoison.Response{body: Poison.encode!(body)}}
      end

      snake = BattleSnake.Api.load(@snake_form, @game_form, mock)

      assert snake == %Snake{
        name: "example-snake",
        color: "#123123",
        url: "http://example.snake",
      }
    end
  end

  describe "BattleSnake.Api.move/3" do
    test "on success responds with the move" do
      mock = fn(:post, "http://example.snake/move", _, _, _) ->
        {:ok, %HTTPoison.Response{body: ~S({"move":"up"})}}
      end

      move = BattleSnake.Api.move(@snake, @world, mock)

      assert move == %Move{
        move: "up"
      }
    end
  end
end
