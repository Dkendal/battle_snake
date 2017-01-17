defmodule BattleSnake.Api do
  alias BattleSnake.{
    HTTP,
    SnakeForm,
    GameForm,
    Snake,
    Move,
    World}

  @callback load(%SnakeForm{}, %GameForm{}) :: %Snake{}
  @callback move(%Snake{}, %World{}) :: %Move{}

  @doc """
  Load the Snake struct based on the configuration_form data for both the world
  and snake.

  POST /start
  """
  def load(snake_form, game_form, request \\ &HTTP.post/4) do
    url = snake_form.url <> "/start"

    snake = %Snake{url: snake_form.url}
    payload = encode_load(game_form)

    with {:ok, response} <- request.(url, payload, headers(), options()),
      do: decode_load(response, snake)
  end

  @doc """
  Get the move for a single snake.

  POST /move
  """
  def move(snake, world, request \\ &HTTP.post/4) do
    url = snake.url <> "/move"

    payload = encode_move(world)

    with {:ok, response} <- request.(url, payload, headers(), options()),
      do: decode_move(response)
  end

  defp options do
    []
  end

  defp headers() do
    []
  end

  @spec decode_move(HTTPoison.Response.t, Move.t) :: {:ok, Move.t} | {:error, any}
  defp decode_move(response, move \\ %Move{}) do
    move = Move.response(move, response)
    Poison.decode(response.body, as: move)
  end

  @spec encode_move(World.t) :: String.t
  defp encode_move(world) do
    Poison.encode!(world)
  end

  @spec decode_load(HTTPoison.Response.t, Snake.t) :: {:ok, Snake.t} | {:error, any}
  defp decode_load(response, snake) do
    Poison.decode(response.body, as: snake)
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
