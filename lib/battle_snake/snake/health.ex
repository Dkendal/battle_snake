defmodule BattleSnake.Snake.Health do
  alias BattleSnake.Snake

  @doc "Set snake as healthy."
  @spec ok(Snake.t) :: Snake.t
  def ok(snake) do
    put_in(snake.health, :ok)
  end

  @doc "Set snake as unhealthy."
  @spec unhealthy(Snake.t) :: Snake.t
  def unhealthy(snake, reason \\ nil) do
    put_in(snake.health, {:error, reason})
  end
end
