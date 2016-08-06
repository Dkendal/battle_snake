defmodule BattleSnakeServer.Snake.Api do
  alias BattleSnake.{Snake, Move, World}
  alias BattleSnakeServer.Snake, as: SnakeForm
  alias BattleSnakeServer.Game

  use HTTPoison.Base

  @callback start() :: {:ok, [atom]} | {:error, any}

  @callback load(%SnakeForm{}, %Game{}) :: %Snake{}

  def load(form, game) do
    url = form.url <> "/start"

    payload = Poison.encode! %{
      game_id: game.id,
      height: game.height,
      width: game.width,
    }

    response = post! url, payload, headers

    Poison.decode!(response.body, as: %Snake{url: form.url})
  end

  @callback move(%Snake{}, %World{}) :: %Move{}

  def move(snake, world) do
    url = snake.url <> "/move"

    payload = Poison.encode!(world)

    response = post! url, payload, headers

    Poison.decode!(response.body, as: %Move{})
  end

  def headers() do
    [{"content-type", "application/json"}]
  end
end
