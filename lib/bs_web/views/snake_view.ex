defmodule BsWeb.SnakeView do
  alias BsWeb.PointView

  use BsWeb, :view

  def render("show.json", %{v: 2, snake: snake}) do
    %{
      object: :snake,
      id: snake.id,
      body: %{
        object: :list,
        data: render_many(snake.coords, PointView, "show.json", v: 2)
      },
      health: snake.health_points,
      name: snake.name,
      taunt: snake.taunt
    }
  end

  def render("show.json", %{v: 1, snake: snake}) do
    %{
      coords: render_many(snake.coords, PointView, "show.json", v: 1),
      health_points: snake.health_points,
      id: snake.id,
      name: snake.name,
      taunt: snake.taunt
    }
  end
end
