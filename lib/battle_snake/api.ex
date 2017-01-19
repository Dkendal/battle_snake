defmodule BattleSnake.Api do
  alias BattleSnake.{
    Api.Response,
    GameForm,
    HTTP,
    Move,
    Snake,
    SnakeForm,
    World}

  @callback load(%SnakeForm{}, %GameForm{}) :: Response.t
  @callback move(%Snake{}, %World{}) :: Response.t

  @doc """
  Load the Snake struct based on the configuration_form data for both the world
  and snake.

  POST /start
  """
  @spec load(%SnakeForm{}, %GameForm{}) :: Response.t
  def load(snake_form, game_form, request \\ &HTTP.post/4) do
    url = snake_form.url <> "/start"

    snake = %Snake{url: snake_form.url}

    url
    |> request.(game_form, headers(), options())
    |> Response.new(as: snake)
  end

  @doc """
  Get the move for a single snake.

  POST /move
  """
  @spec move(%Snake{}, %World{}) :: Response.t
  def move(snake, world, request \\ &HTTP.post/4) do
    url = snake.url <> "/move"

    url
    |> request.(world, headers(), options())
    |> Response.new(as: %Move{})
  end

  defp options do
    []
  end

  defp headers() do
    []
  end
end
