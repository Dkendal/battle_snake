defmodule BattleSnakeServer.PlayView do
  use BattleSnakeServer.Web, :view

  def render("square.html", %{state: state, y: y, x: x}) do
    square = state.map[x][y]

    square_state = square["state"]

    rect(square_state, x, y)
  end

  def rect(nil, _, _) do
    ""
  end

  def rect(square_state, x, y) do
    fill = case square_state do
      "head" -> "red"

      "body" -> "blue"

      "food" -> "green"
    end

    style = "fill: #{fill};"

    content_tag(:rect, "", x: x, y: y, width: 1, height: 1, style: style)
  end
end
