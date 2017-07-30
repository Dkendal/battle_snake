defmodule BattleSnake.ApiTest do
  alias BattleSnake.{Snake, Point, Move, Api}

  use BattleSnake.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @http_error %HTTPoison.Error{}
  @move_url "http://example.snake/move"
  @start_url "http://example.snake/start"

  @snake_form %BattleSnakeWeb.SnakeForm{
    url: "http://example.snake"
  }

  @game_form %BattleSnakeWeb.GameForm{}

  @snake %BattleSnake.Snake{
    id: "1234",
    name: "me",
    url: "http://example.snake",
    coords: [%Point{x: 0, y: 0}]
  }

  @world %BattleSnake.World{
    snakes: [@snake]
  }

  describe "Api.load/3" do
    test "on success produces a snake" do
      body = %{
        name: "example-snake",
        color: "#123123"
      }

      http_response = %HTTPoison.Response{body: Poison.encode!(body)}

      mock = fn (@start_url, _, _, _) ->
        {:ok, http_response}
      end

      response = Api.load(@snake_form, @game_form, mock)

      assert(match? %Api.Response{}, response)

      assert({:ok, http_response} == response.raw_response)

      assert(response.parsed_response == {
        :ok,
        %Snake{
          name: "example-snake",
          color: "#123123",
          url: "http://example.snake"}})
    end

    test "on error returns the error" do
      mock = fn (@start_url, _, _, _) ->
        {:error, @http_error}
      end

      response =  Api.load(@snake_form, @game_form, mock)

      assert(match? %Api.Response{}, response)

      assert({:error, @http_error} == response.raw_response)

      assert(response.parsed_response == {:error, :no_response})
    end
  end

  describe "Api.move/3" do
    test "sets an error when the move is invalid" do
      raw_response = %HTTPoison.Response{body: ~S({"move":"north"})}

      mock = fn(@move_url, body, _, _) ->
        send(self(), Poison.decode(body))
        {:ok, raw_response}
      end

      move = Api.move(@snake, @world, mock)

      assert %Api.Response{
        url: "http://example.snake/move",
        raw_response: {:ok, ^raw_response},
        parsed_response: {:error, changeset}} = move

      assert changeset.errors == [move: {"is invalid", [validation: :inclusion]}]

      assert_receive {:ok, %{"you" => "1234"}}
    end

    test "on success responds with the move" do
      raw_response = %HTTPoison.Response{body: ~S({"move":"up"})}

      mock = fn(@move_url, body, _, _) ->
        send(self(), Poison.decode(body))
        {:ok, raw_response}
      end

      move = Api.move(@snake, @world, mock)

      assert move == %Api.Response{
        url: "http://example.snake/move",
        raw_response: {
          :ok,
          raw_response},
        parsed_response: {
          :ok,
          %Move{move: "up"}}}

      assert_receive {:ok, %{"you" => "1234"}}
    end

    test "on parsing error returns the error" do
      body = "<html></html>"

      raw_response = %HTTPoison.Response{body: body}

      mock = fn (@move_url, _, _, _) ->
        {:ok, raw_response}
      end

      move = Api.move(@snake, @world, mock)

      assert move == %Api.Response{
        url: "http://example.snake/move",
        raw_response: {
          :ok,
          raw_response},
        parsed_response: {
          :error,
          {:invalid, "<", 0}}}
    end

    test "on error returns the error" do
      mock = fn (@move_url, _, _, _) ->
        {:error, @http_error}
      end

      move = Api.move(@snake, @world, mock)

      assert move == %Api.Response{
        url: "http://example.snake/move",
        raw_response: {
          :error,
          @http_error},
        parsed_response: {
          :error,
          :no_response}}
    end
  end
end
