defmodule BattleSnake.BoardViewerView do
  alias BattleSnake.Snake
  alias BattleSnake.Point
  use BattleSnake.Web, :view
  use BattleSnake.Point

  @snake_stroke_width 0.03
  @food_r 0.25
  @factor 0.8
  @center 0.5
  @polyline_term_offset 0.38
  @offset (1 - @factor) / 2
  @trans -@center * (@factor - 1)
  @transform "translate(#{to_string @trans}, #{to_string @trans}) scale(#{to_string @factor})"

  def snake_polyline_points(body, acc \\ [])

  def snake_polyline_points([], acc) do
    Enum.join(acc, ",")
  end

  def snake_polyline_points([h, h1|t], []) do
    # Move the first segment of the polyline so that it overlaps with the head
    # svg
    v = h1
    |> Point.sub(h)
    |> Point.mul(@polyline_term_offset)
    |> Point.add(h)
    |> do_snake_polyline_points

    snake_polyline_points [h1|t], [v]
  end

  def snake_polyline_points([t1, t], acc) do
    # Move the last segment of the polyline so that overlaps with the tail svg
    v = t1
    |> Point.sub(t)
    |> Point.mul(@polyline_term_offset)
    |> Point.add(t)
    |> do_snake_polyline_points

    acc = [v, do_snake_polyline_points(t1)|acc]
    snake_polyline_points([], acc)
  end

  def snake_polyline_points([h|t], acc) do
    v = do_snake_polyline_points(h)
    snake_polyline_points t, [v|acc]
  end

  def do_snake_polyline_points(point) do
    p(x, y) = Point.add(point, 0.5)
    "#{x} #{y}"
  end

  def dead_snakes(world) do
    Enum.sort_by(world.dead_snakes, &(&1.name), &<=/2)
  end

  def snakes(world) do
    Enum.sort_by(world.snakes, &(&1.name), &<=/2)
  end

  def transform_segment(h1, []) do
    ""
  end

  def transform_segment(h1, [h2]) do
    v = Point.sub(h2, h1)
    sx = -1
    sy = 1
    p(cx, cy) =  Point.add h1, 0.5
    case v do
      p(1, 0) -> "matrix(#{sx}, 0, 0, #{sy}, #{cx-sx*cx}, #{cy-sy*cy})" # flip horizontally around a point
      p(0, -1) -> "rotate(90, #{cx}, #{cy})"
      p(0, 1) -> "rotate(-90, #{cx}, #{cy})"
      _ -> ""
    end
  end

  def food_obj(point) do
    content_tag(:circle, "",
      cy: point.y + 0.5,
      cx: point.x + 0.5,
      r: @food_r,
      class: "obj-food")
  end

  def head_image_url(%{url: base, head_url: "/" <> url}) do
    base <> "/" <> url
  end

  def head_image_url(%{head_url: url}) do
    url
  end
end
