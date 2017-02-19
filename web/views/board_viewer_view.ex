defmodule BattleSnake.BoardViewerView do
  alias BattleSnake.Snake
  alias BattleSnake.Point
  use BattleSnake.Web, :view
  use BattleSnake.Point

  @snake_stroke_width 0.03
  @food_r 0.25
  @factor 0.8
  @center 0.5
  @offset (1 - @factor) / 2
  @trans -@center * (@factor - 1)
  @transform "translate(#{to_string @trans}, #{to_string @trans}) scale(#{to_string @factor})"

  defmacrop is_kink(x1, y1, x2, y2) do
    quote do
      abs(unquote(x2) - unquote(x1)) == 1
      and abs(unquote(y2) - unquote(y1)) == 1
    end
  end

  def dead_snakes(world) do
    Enum.sort_by(world.dead_snakes, &(&1.name), &<=/2)
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

  def snake_pattern(%BattleSnake.World{} = world, acc) do
    snake_pattern(world.snakes)
  end

  def snake_pattern(snakes, acc \\ [])

  def snake_pattern([], acc) do
    acc
  end

  def snake_pattern([%BattleSnake.Snake{} = h|t], acc) do
    snake_pattern(t, [snake_pattern(h)|acc])
  end

  def snake_pattern(%BattleSnake.Snake{} = snake, _acc) do
    snake_segment_pattern(~w(head tail kink body)a, snake, [])
  end

  def snake_segment_pattern([], _snake, acc), do: acc

  def snake_segment_pattern([segment|t], snake, acc) do
    id = snake_pattern_id(snake, segment)
    href = snake_segment_href(snake, segment)
    href = translate_href(snake, href)
    value = snake_segment_pattern_image(id, href)
    snake_segment_pattern(t, snake, [value|acc])
  end

  def snake_segment_pattern_image(id, nil), do: nil

  def snake_segment_pattern_image(id, href) do
    image = content_tag(:image, "",
      "xlink:href": href,
      x: @offset, y: @offset,
      width: @factor, height: @factor)
    content_tag(:pattern, [image],
      id: id,
      patternContentUnits: "objectBoundingBox",
      width: 1, height: 1)
  end

  @doc """
  Convert a relative path to an absolute one
  """
  def translate_href(snake, "/" <> url),
    do: snake.url <> "/" <> url

  def translate_href(_snake,  url),
    do: url

  def snake_segment_href(snake, :kink),
    do: snake.kink_url

  def snake_segment_href(snake, :tail),
    do: snake.tail_url

  def snake_segment_href(snake, :body),
    do: snake.body_url

  def snake_segment_href(snake, :head),
    do: snake.head_url

  def snake_segment_href(snake, segment),
    do: nil

  def snake_pattern_id(snake, segment),
    do: to_string(snake.id) <> "-" <> to_string(segment)

  def segment_rotation(p(x1, y1), p(x2, y2), p(x3, y3))
    when is_kink(x1, y1, x3, y3) and true do
    x = (x1 - x2) - (x2 - x3)
    y = (y1 - y2) - (y2 - y3)

    case {x, y} do
      {1, 1} -> 180
      {-1, 1} -> -90
      {-1, -1} -> 0
      {1, -1} -> 90
      _ ->
        IO.inspect {x, y}
        45
    end
  end

  def segment_rotation(p(x1, y), p(x2, y), _prev),
    do: if x2 - x1 > 0, do: 0, else: 180

  def segment_rotation(p(x, y1), p(x, y2), _prev),
    do: if y2 - y1 > 0, do: 90, else: -90

  def segment_rotation(_prev, p(x, y1), p(x, y2)),
    do: if y2 - y1 > 0, do: -90, else: 90

  def segment_rotation(_prev, p(x1, y), p(x2, y)),
    do: if x2 - x1 > 0, do: 180, else: 0

  def segment_rotation(prev, current, next) do
    45
  end

  def do_snake_obj(prev, current, next, snake, index) do
    deg = segment_rotation(prev, current, next)
    point = current
    transform = "rotate(#{deg} #{point.x + 0.5} #{point.y + 0.5})"

    fill = "url(##{snake.id}-body) #{snake.color}"

    value = content_tag(:rect, "",
      y: point.y,
      x: point.x,
      width: 1,
      height: 1,
      fill: snake_obj_fill(snake, index),
      fill_opacity: snake_obj_fill_opacity(snake, index),
      transform: transform,
      class: "obj-snake")
  end

  def snake_obj([], _snake, _index, acc), do: acc

  # Head
  def snake_obj([current, next|t], snake, 1, acc) do
    snake_obj([current, next|t], snake, 2, [do_snake_obj(:none, current, next, snake, 1)|acc])
  end

  # Tail
  def snake_obj([prev, current], snake, index, acc) do
    acc = [do_snake_obj(prev, current, :none, snake, index)|acc]
    snake_obj([], snake, index + 1, acc)
  end

  # Body
  def snake_obj([prev, current, next|t], snake, index, acc) do
    acc = [do_snake_obj(prev, current, next, snake, index)|acc]
    coords = [current, next|t]
    snake_obj(coords, snake, index + 1, acc)
  end

  def snake_obj(%Snake{} = snake) do
    snake_obj(snake.coords, snake, 1, [])
  end

  def snake_obj(snakes, acc \\ [])

  def snake_obj([], acc), do: acc

  def snake_obj([%Snake{} = snake|t], acc) do
    snake_obj(t, [snake_obj(snake)|acc])
  end

  @doc """
  Render a rectangle for a single segment of the snake.
  """
  def snake_obj(point, snake, index) do
    Enum.slice(snake.coords, (index - 2), 3)

    deg = 90
    transform = "rotate(#{deg} #{point.x + 0.5} #{point.y + 0.5})"

    fill = "url(##{snake.id}-body) #{snake.color}"

    content_tag(:rect, "",
      y: point.y,
      x: point.x,
      width: 1,
      height: 1,
      fill: snake_obj_fill(snake, index),
      fill_opacity: snake_obj_fill_opacity(snake, index),
      transform: transform,
      class: "obj-snake")
  end

  def snake_obj_fill_opacity(snake, index) do
    (1 - index / length(snake.coords) + 0.3)
  end

  def snake_obj_fill(snake, index \\ :default)

  def snake_obj_fill(snake, 1),
    do: snake_obj_pattern_url(snake, :head) <> " " <> snake_obj_fill(snake)

  def snake_obj_fill(snake, :default),
    do: snake.color

  def snake_obj_fill(%{coords: coords} = snake, index)
  when length(coords) == index,
    do: snake_obj_pattern_url(snake, :tail) <> " " <> snake_obj_fill(snake)

  def snake_obj_fill(snake, index) do
    segment =
      Enum.slice(snake.coords, (index - 2), 3)
      |> case do
           [p(x1, y1), _, p(x2, y2)] when is_kink(x1, y1, x2, y2) ->
             :kink

           _ ->
             :body
         end

    fill = snake_obj_pattern_url(snake, segment)
    fill <> " " <> snake_obj_fill(snake)
  end

  def snake_obj_pattern_url(snake, segment),
    do: "url(#" <> snake_pattern_id(snake, segment) <> ")"

  def food_obj(point) do
    content_tag(:circle, "",
      cy: point.y + 0.5,
      cx: point.x + 0.5,
      r: @food_r,
      class: "obj-food")
  end

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

end
