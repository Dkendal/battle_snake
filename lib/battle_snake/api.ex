defmodule BattleSnake.Api do
  alias BattleSnake.{
    HTTP,
    SnakeForm,
    GameForm,
    Snake,
    Move,
    World}

  @callback start() :: {:ok, [atom]} | {:error, any}

  @shortdoc "POST /start"
  @doc """
  Load the Snake struct based on the configuration form data for both the world
  and snake.
  """
  @callback load(%SnakeForm{}, %GameForm{}) :: %Snake{}
  def load(form, game, request \\ &HTTP.post/4) do
    url = form.url <> "/start"

    payload = Poison.encode! %{
      game_id: game.id,
      height: game.height,
      width: game.width,
    }

    {:ok, response} = request.(url, payload, headers(), options())

    Poison.decode!(response.body, as: %Snake{url: form.url})
  end

  @shortdoc "POST /move"
  @doc "Get the move for a single snake."
  @callback move(%Snake{}, %World{}) :: %Move{}
  def move(snake, world, request \\ &HTTP.post/4) do
    url = snake.url <> "/move"

    payload = Poison.encode!(world)

    {:ok, response} = request.(url, payload, headers(), options())

    Poison.decode!(response.body, as: %Move{})
  end

  def options do
    []
  end

  def headers() do
    []
  end
end
