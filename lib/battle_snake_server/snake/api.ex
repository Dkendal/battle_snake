defmodule BattleSnakeServer.Snake.Api do
  alias BattleSnake.Snake

  use HTTPoison.Base

  @spec load(BattleSnakeServer.Snake, BattleSnakeServer.Game) :: BattleSnake.Snake
  def load(snake, game) do
    url = snake.url <> "/start"
    response = post! url, payload(game), headers
    Poison.decode!(response.body, as: %Snake{})
  end

  def load(snake, game) do
    url = snake.url <> "/start"
    response = post! url, payload(game), headers
    Poison.decode!(response.body, as: %Snake{})
  end

  def payload(game) do
    %{
      game_id: game.id,
      height: game.height,
      width: game.width,
    } |> Poison.encode!
  end

  def headers() do
    [{"content-type", "application/json"}]
  end
end
