defmodule BsWeb.SnakeView do
  alias BsWeb.Api.DeathView
  alias BsWeb.PointView

  use BsWeb, :view

  def render("show.json", %{v: 2, snake: snake} = assigns) do
    data = %{
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

    data =
      if snake.death do
        Map.merge(data, %{
          death: render_one(
            snake.death,
            DeathView,
            "show.json"
          )
        })
      else
        data
      end

    if assigns[:include_render_props] do
      Map.merge(data, %{
        color: snake.color,
        headType: snake.head_type,
        tailType: snake.tail_type,
        headUrl: snake.head_url
      })
    else
      data
    end
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
