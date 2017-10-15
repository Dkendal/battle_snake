defmodule BsWeb.WorldView do
  alias BsWeb.SnakeView
  alias BsWeb.PointView

  use BsWeb, :view

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
