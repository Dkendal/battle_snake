defmodule BattleSnake.Api do
  alias BattleSnake.{
    Api.Response,
    GameForm,
    HTTP,
    Move,
    Snake,
    SnakeForm,
    World}

  require Logger

  @load_whitelist ~w(color head_url name taunt)a
  @move_whitelist ~w(move taunt)a

  @callback load(%SnakeForm{}, %GameForm{}) :: Response.t
  @callback move(%Snake{}, %World{}) :: Response.t

  @doc """
  Load the Snake struct based on the configuration_form data for both the world
  and snake.

  POST /start
  """
  @spec load(%SnakeForm{}, %GameForm{}) :: Response.t
  def load(%{url: url}, data, request \\ &HTTP.post/4) do
    request_url = url <> "/start"
    api_response = response(request_url, request, Snake, @load_whitelist, data)
    update_in(api_response.parsed_response, fn
      {:ok, snake} ->
      (
        snake = put_in(snake.url, url)
        {:ok, snake}
      )
      error ->
      (
        http_response = inspect(api_response.raw_response, color: false, pretty: true)
        ("""
        Could not process API response for #{request_url}:

        Poison JSON Parsing Error:
        #{inspect error}

        HTTPoison HTTP Response:
        #{http_response}
        """)
        |> Logger.debug
        error
      )
    end)
  end

  @doc """
  Get the move for a single snake.

  POST /move
  """
  @spec move(%Snake{}, %World{}) :: Response.t
  def move(%{url: url, id: id}, world, request \\ &HTTP.post/4) do
    data = Poison.encode!(world, me: id)
    response(url <> "/move", request, Move, @move_whitelist, data)
  end

  defp response(url, request, type, whitelist, data) do
    st = struct(type)
    api_response = url
    |> request.(data, [], [])
    |> Response.new(as: st)

    update_in(api_response.parsed_response, fn
      {:ok, snake} ->
      (
        map = Map.take(snake, whitelist)
        snake = struct(type, map)
        {:ok, snake}
      )
      error -> error
    end)
  end
end
