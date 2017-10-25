defmodule BsWeb.BoardView do
  use BsWeb, :view

  def render("snake.json", %{snake: snake}) do
    %{
      health: snake.health_points,
      coords: snake.coords,
      color: snake.color,
      id: snake.id,
      name: snake.name,
      taunt: snake.taunt,
      headType: snake.head_type,
      tailType: snake.tail_type,
      headUrl: snake.head_url
    }
  end

  def render("show.json", %{board: board}) do
    snakes = &render_many(&1, __MODULE__, "snake.json", as: :snake)

    %{
      width: board.width,
      height: board.height,
      gameId: board.game_id,
      turn: board.turn,
      food: board.food,
      deadSnakes: snakes.(board.dead_snakes),
      snakes: snakes.(board.snakes)
    }
  end
end
