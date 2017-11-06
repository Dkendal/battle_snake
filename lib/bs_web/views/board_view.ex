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

    if snake.death do
      Map.merge(data, %{
        death: render_one(snake.death, BsWeb.Api.DeathView, "show.json")
      })
    else
      data
    end
  end

  def render("show.json", %{board: world}) do
    snakes = &render_many(&1, __MODULE__, "snake.json", as: :snake)

    %{
      id: world.id,
      deadSnakes: snakes.(world.dead_snakes),
      food: world.food,
      gameId: world.game_id,
      height: world.height,
      snakes: snakes.(world.snakes),
      turn: world.turn,
      width: world.width
    }
  end
end
