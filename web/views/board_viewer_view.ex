defmodule BattleSnake.BoardViewerView do
  use BattleSnake.Web, :view

  @snake_stroke_width 0.03
  @food_r 0.25

  def snake_obj(point, snake, index) do
    fill_opacity = (1 - index / length(snake.coords) + 0.3)

    content_tag(:rect, "",
      y: (point.y + @snake_stroke_width),
      x: (point.x + @snake_stroke_width),
      width: (1 - @snake_stroke_width * 2),
      height: (1 - @snake_stroke_width * 2),
      fill: snake.color,
      fill_opacity: fill_opacity,
      class: "obj-snake")
  end

  def food_obj(point) do
    content_tag(:circle, "",
      cy: point.y + 0.5,
      cx: point.x + 0.5,
      r: @food_r,
      class: "obj-food")
  end
end
