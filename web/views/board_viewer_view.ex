defmodule BattleSnake.BoardViewerView do
  use BattleSnake.Web, :view

  @snake_stroke_width 0.03
  @food_r 0.25

  @factor 0.8
  @center 0.5
  @trans -@center * (@factor - 1)
  @transform "translate(#{to_string @trans}, #{to_string @trans}) scale(#{to_string @factor})"

  def translate_and_scale(x, y, factor) do
    translate(x, y, factor) <> " " <> scale(factor)
  end

  defp scale(factor) do
    "scale(#{to_string factor})"
  end

  defp translate(x, y, factor) do
    trans_x = translate(x, factor)
    trans_y = translate(y, factor)
    "translate(#{to_string trans_x}, #{to_string trans_y})"
  end

  defp translate(v, factor) do
    -v * (factor - 1)
  end

  def snakes(world) do
    Enum.sort_by(world.snakes, &(&1.name), &<=/2)
  end

  def board_tile(opts \\ []) do
    defaults = [
      x: 0,
      y: 0,
      width: 1,
      height: 1,
      transform: @transform]

    content_tag(:rect, "", Keyword.merge(defaults, opts))
  end

  def snake_obj(point, snake, index) do
    fill_opacity = (1 - index / length(snake.coords) + 0.3)
    transform = translate_and_scale(point.x + @center, point.y + @center, @factor)

    content_tag(:rect, "",
      y: point.y,
      x: point.x,
      width: 1,
      height: 1,
      fill: snake.color,
      fill_opacity: fill_opacity,
      transform: transform,
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
