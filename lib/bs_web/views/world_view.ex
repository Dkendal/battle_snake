defmodule BsWeb.WorldView do
  alias BsWeb.SnakeView
  alias BsWeb.PointView

  use BsWeb, :view

  def render("show.json", %{v: 2, world: world, snake: snake}) do
    %{
      object: :world,
      id: world.game_id,
      height: world.height,
      turn: world.turn,
      width: world.width,
      you: render(SnakeView, "show.json", snake: snake, v: 2),
      food: %{
        object: :list,
        data: render_many(world.food, PointView, "show.json", v: 2)
      },
      snakes: %{
        object: :list,
        data: render_many( world.snakes, SnakeView, "show.json", v: 2)
      }
    }
  end

  def render("show.json", %{v: 1, world: world, snake: snake}) do
    %{
      dead_snakes: render_many(
        world.dead_snakes,
        SnakeView,
        "show.json",
        v: 1,
      ),
      food: render_many(world.food, PointView, "show.json", v: 1),
      game_id: world.game_id,
      height: world.height,
      snakes: render_many(
        world.snakes,
        SnakeView,
        "show.json",
        v: 1,
      ),
      turn: world.turn,
      width: world.width,
      you: snake.id
    }
  end
end
