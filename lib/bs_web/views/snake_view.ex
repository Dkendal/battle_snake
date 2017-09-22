defmodule BsWeb.SnakeView do
  alias Bs.Point
  alias Bs.Death
  alias Bs.GameState
  use BsWeb, :view
  use Bs.Point

  def render("score.html", %{snake: snake, state: state}) do
    if snake.cause_of_death == nil do
      render_one(snake, __MODULE__, "score_live.html", %{state: state})
    else
      render_one(snake, __MODULE__, "score_dead.html", %{state: state})
    end
  end

  def render("score.html", %{state: state}) do
    mapper = fn snake ->
      case snake.cause_of_death do
        %{turn: turn} -> turn
        nil -> {snake.name, snake.id}
      end
    end

    stream = Stream.concat(state.world.snakes, state.world.dead_snakes)

    snakes = Enum.sort_by(stream, mapper, &>=/2)

    render_many(snakes, __MODULE__, "score.html", %{state: state})
  end

  def head_image_url(%{url: base, head_url: "/" <> url}) do
    base <> "/" <> url
  end

  def head_image_url(%{head_url: url}) do
    url
  end

  def cause_of_death_text(cause, state) do
    alias Bs.Death
    case cause do
      %Death.StarvationCause{} ->
        "Starved to death"
      %Death.WallCollisionCause{} ->
        "Crashed into a wall"
      %Death.SelfCollisionCause{} ->
        "Collided with itself"
      %Death.BodyCollisionCause{with: id} ->
        "Collided with #{get_in state, [:snakes, id, :name]}'s body"
      %Death.HeadCollisionCause{with: id} ->
        "Consumed by #{get_in state, [:snakes, id, :name]}"
      _ ->
        ""
    end
  end

  def snake_path(snake) do
    Enum.reduce(snake.coords, [{nil, nil}], fn v, acc ->
      case {v, acc} do
        {v, [{nil, nil} | acc]} ->
          [{v, nil} | acc]

        {v, [{s, nil} | acc]} ->
          [{s, v} | acc]

        {p(x, _y0), [{p(x, _y1) = s, p(x, _y2)} | acc]} ->
          [{s, v} | acc]

        {p(_x0, y), [{p(_x1, y) = s, p(_x2, y)} | acc]} ->
          [{s, v} | acc]

        {v, [{_, e} | _] = acc} ->
          [{e, v} | acc]

        {v, acc} ->
          [{v, nil} | acc]
      end
    end)
    |> do_snake_path
  end

  defp scale_vector({a, b}) do
    import Point
    offset = 0.39

    c = b
    |> sub(a)
    |> mul(0.5)
    |> add(b)

    a0 = a
    |> sub(c)
    sa = if mag(a0) == 0,
      do: 0,
      else: (mag(a0) - offset) / mag(a0)
    a0 = a0
    |> mul(sa)
    |> add(c)

    b0 = b
    |> sub(c)
    sb = if mag(b0) == 0,
      do: 0,
      else: (mag(b0) + offset) / mag(b0)
    b0 = b0
    |> mul(sb)
    |> add(c)

    {a0, b0}
  end

  defp do_snake_path(_, _ \\ [])

  defp do_snake_path([], acc) do
    acc
    |> Stream.map(& to_string &1)
    |> Stream.map(& [&1, " "])
    |> Enum.reverse
  end

  defp do_snake_path([{a, b}], []) do
    {c, d} = scale_vector({a, b})
    acc = [c.y, c.x, "L",
           d.y, d.x, "M"]
    do_snake_path([], acc)
  end

  defp do_snake_path([{a, b} | rest], []) do
    {_c, d} = scale_vector({a, b})
    acc = [a.y, a.x, "L",
           d.y, d.x, "M"]
    do_snake_path(rest, acc)
  end

  defp do_snake_path([{a, b}], acc) do
    {c, _} = scale_vector({a, b})
    acc = [c.y, c.x, "L",
           b.y, b.x, "L"| acc]
    do_snake_path([], acc)
  end

  defp do_snake_path([{a, b} | rest], acc) do
    acc = [a.y, a.x, "L",
           b.y, b.x, "L"|
           acc]
    do_snake_path(rest, acc)
  end

  def dead_snakes(world) do
    Enum.sort_by(world.dead_snakes, &(&1.name), &<=/2)
  end

  def snakes(world) do
    Enum.sort_by(world.snakes, &(&1.name), &<=/2)
  end

  def transform_segment(_, []) do
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
end
