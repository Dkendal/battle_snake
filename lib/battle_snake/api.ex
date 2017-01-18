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
    payload = encode_load(game_form)

    url
    |> request.(payload, headers(), options())
    |> Response.new(as: snake)
  end

  @doc """
  Get the move for a single snake.

  POST /move
  """
  @spec move(%Snake{}, %World{}) :: Response.t
  def move(snake, world, request \\ &HTTP.post/4) do
    url = snake.url <> "/move"

    payload = encode_move(world)

    url
    |> request.(payload, headers(), options())
    |> Response.new(as: %Move{})
  end

  defp options do
    []
  end

  defp headers() do
    []
  end

  @spec encode_move(World.t) :: String.t
  defp encode_move(world) do
    Poison.encode!(world)
  end

  @spec encode_load(GameForm.t) :: String.t
  defp encode_load(game_form) do
    Poison.encode! %{
      game_id: game_form.id,
      height: game_form.height,
      width: game_form.width,
    }
  end
end
