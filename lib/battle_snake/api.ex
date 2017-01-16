defmodule BattleSnake.Api do
  alias BattleSnake.{Snake, Move, World}
  alias BattleSnake.SnakeForm
  alias BattleSnake.GameForm

  use HTTPoison.Base

  @callback start() :: {:ok, [atom]} | {:error, any}

  @doc """
  Load the Snake struct based on the configuration form data for both the world
  and snake.
  """
  @callback load(%SnakeForm{}, %GameForm{}) :: %Snake{}
  def load(form, game, request \\ &request/5) do
    url = form.url <> "/start"

    payload = Poison.encode! %{
      game_id: game.id,
      height: game.height,
      width: game.width,
    }

    {:ok, response} = request.(:post, url, payload, headers(), options())

    Poison.decode!(response.body, as: %Snake{url: form.url})
  end

  @doc "Get the move for a single snake."
  @callback move(%Snake{}, %World{}) :: %Move{}
  def move(snake, world, request \\ &request/5) do
    url = snake.url <> "/move"

    payload = Poison.encode!(world)

    {:ok, response} = request.(:post, url, payload, headers(), options())

    Poison.decode!(response.body, as: %Move{})
  end

  def options do
    []
  end

  def headers() do
    [{"content-type", "application/json"}]
  end
end
