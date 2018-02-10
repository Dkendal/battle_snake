defmodule BsWeb.Board.SnakeView do
  use BsWeb, :view

  def render("show.json", %{snake: record}) do
    %{
      color: record.color,
      coords: record.coords,
      headType: record.head_type,
      headUrl: record.head_url,
      health: record.health_points,
      id: record.id,
      name: record.name,
      status: record.status,
      tailType: record.tail_type,
      taunt: record.taunt
    }
  end
end
