defmodule BattleSnake.ApiTest do
  alias BattleSnake.{Snake, Point, Move}

  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @move_url "http://example.snake/move"
  @start_url "http://example.snake/start"

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

      mock = fn (@start_url, _, _, _) ->
        {:ok, %HTTPoison.Response{body: Poison.encode!(body)}}
      end

      snake = BattleSnake.Api.load(@snake_form, @game_form, mock)

      assert snake == %Snake{
        name: "example-snake",
        color: "#123123",
        url: "http://example.snake",
      }
    end

    test "on error returns the error" do
      mock = fn (@start_url, _, _, _) ->
        {:error, %HTTPoison.Error{}}
      end

      assert({:error, %HTTPoison.Error{}} ==
        BattleSnake.Api.load(@snake_form, @game_form, mock))
    end
  end

  describe "BattleSnake.Api.move/3" do
    # {:error, %HTTPoison.Error{id: nil, reason: :econnrefused}}
    test "on success responds with the move" do
      mock = fn(@move_url, _, _, _) ->
        {:ok, %HTTPoison.Response{body: ~S({"move":"up"})}}
      end

      move = BattleSnake.Api.move(@snake, @world, mock)

      assert move == %Move{
        move: "up"
      }
    end

    test "on error returns the error" do
      mock = fn (@move_url, _, _, _) ->
        {:error, %HTTPoison.Error{}}
      end

      assert({:error, %HTTPoison.Error{}} ==
        BattleSnake.Api.move(@snake, @game, mock))
    end
  end
end
