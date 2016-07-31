defmodule BattleSnakeServer.PlayView do
  use BattleSnakeServer.Web, :view

  def render("square.html", %{world: world, y: y, x: x}) do
    square = world.map[x][y]

    square_world = square["world"]

    rect(square_world, x, y)
  end

  def rect(nil, _, _) do
    ""
  end

  def rect(square_world, x, y) do
    fill = case square_world do
      "head" -> "red"

      "body" -> "blue"

      "food" -> "green"
    end

    style = "fill: #{fill};"

    content_tag(:rect, "", x: x, y: y, width: 1, height: 1, style: style)
  end
end
