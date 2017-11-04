defmodule BsWeb.BoardView do
  use BsWeb, :view

  def render("snake.json", %{snake: snake}) do
    data = %{
      color: snake.color,
      coords: snake.coords,
      headType: snake.head_type,
      headUrl: snake.head_url,
      health: snake.health_points,
      id: snake.id,
      name: snake.name,
      tailType: snake.tail_type,
      taunt: snake.taunt
    }

    data =
      if snake.death do
        Map.merge(data, %{
          death: render_one(
            snake.death,
            BsWeb.Api.DeathView,
            "show.json"
          )
        })
      else
        data
      end
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
