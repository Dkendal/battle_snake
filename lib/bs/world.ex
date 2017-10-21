defmodule Bs.World do
  use Ecto.Schema

  alias Bs.Point
  alias Bs.Snake
  alias Bs.Point

  use Point

  defmodule DeathEvent do
    defstruct [:turn, :snake]
  end

  embedded_schema do
    field(:game_form_id, :any, virtual: true)
    field(:created_at, :any, virtual: true)
    field(:food, :any, default: [], virtual: true)
    field(:snakes, :any, default: [], virtual: true)
    field(:dead_snakes, :any, default: [], virtual: true)
    field(:max_food, :any, default: 2, virtual: true)
    field(:height, :any, default: 10, virtual: true)
    field(:width, :any, default: 10, virtual: true)
    field(:turn, :any, default: 0, virtual: true)
    field(:moves, :any, default: %{}, virtual: true)
    field(:deaths, :any, default: [], virtual: true)
    field(:game_id, :any, default: 0, virtual: true)
  end

  @doc """
  Restock food on the board.
  """
  def stock_food(world) do
    i = world.max_food - length(world.food)
    i = max(i, 0)
    do_stock_food(i, world)
  end

  defp do_stock_food(0, world) do
    world
  end

  defp do_stock_food(i, world) do
    point = rand_unoccupied_space(world)
    do_stock_food(point, i, world)
  end

  defp do_stock_food({:ok, point}, i, world) do
    world = update_in(world.food, &[point | &1])
    do_stock_food(i - 1, world)
  end

  defp do_stock_food({:error, _}, _, world) do
    world
  end

  def rand_unoccupied_space(%{width: w, height: h} = world) when w > 0 and h > 0 do
    spaces = Stream.flat_map(world.snakes, & &1.coords)
    spaces = Stream.concat(spaces, world.food)
    spaces = Enum.into(spaces, MapSet.new())
    width = world.width - 1
    height = world.height - 1

    stream =
      Stream.flat_map(0..width, fn x ->
        Stream.flat_map(0..height, fn y -> [p(x, y)] end)
      end)

    stream = Stream.filter(stream, fn p -> !MapSet.member?(spaces, p) end)

    open = Enum.to_list(stream)

    if length(open) == 0 do
      {:error, :empty_error}
    else
      {:ok, Enum.random(open)}
    end
  end

  @doc "increase world.turn by 1"
  def inc_turn(world) do
    update_in(world.turn, &(&1 + 1))
  end

  def step(world) do
    world
    |> inc_turn
    |> dec_health_points
    |> grow_snakes
    |> remove_eaten_food
    |> stock_food
  end

  @doc "Reduce all snakes health points by 1"
  def dec_health_points(world) do
    update_in(world.snakes, fn snakes ->
      Enum.map(snakes, &Snake.dec_health_points/1)
    end)
  end

  @doc """
  Move any snakes from .snakes that died this turn into .dead_snakes.
  """
  def clean_up_dead(world) do
    snakes = world.snakes

    acc = %{live: [], dead: []}

    acc =
      Enum.reduce(snakes, acc, fn snake, acc ->
        f = &[snake | &1]

        if Snake.dead?(snake, world) do
          update_in(acc.dead, f)
        else
          update_in(acc.live, f)
        end
      end)

    world = put_in(world.snakes, acc.live)
    world = update_in(world.dead_snakes, &(&1 ++ acc.dead))

    living_snakes = Snake.resolve_head_to_head(acc.live)
    head_to_head_dead = acc.live -- living_snakes

    world = update_in(world.dead_snakes, &(&1 ++ head_to_head_dead))

    world =
      update_in(world.deaths, fn _deaths ->
        dead = acc.dead ++ head_to_head_dead
        for snake <- dead, do: %DeathEvent{turn: world.turn, snake: snake}
      end)

    put_in(world.snakes, living_snakes)
  end

  def grow_snakes(world) do
    update_in(world.snakes, fn snakes ->
      for snake <- snakes do
        increase = grew(world, snake)

        if increase > 0 do
          snake
          |> Snake.reset_health_points()
          |> Snake.grow(increase)
        else
          snake
        end
      end
    end)
  end

  def remove_eaten_food(world) do
    update_in(world.food, fn food -> Enum.reject(food, &eaten?(world, &1)) end)
  end

  def eaten?(world, apple) do
    Enum.any?(world.snakes, fn
      %{coords: [^apple | _]} ->
        true

      _ ->
        false
    end)
  end

  def grew(world, snake) do
    head = hd(snake.coords)

    if head in world.food do
      1
    else
      0
    end
  end

  def cols(world) do
    0..(world.width - 1)
  end

  def rows(world) do
    0..(world.height - 1)
  end

  def map(world, f) do
    for x <- cols(world) do
      for y <- rows(world) do
        p = %Point{x: x, y: y}
        f.(p)
      end
    end
  end

  def find_snake(world, id) do
    Enum.find(world.snakes ++ world.dead_snakes, &(&1.id == id))
  end

  def changeset(world, params) do
    import Ecto.Changeset

    permitted = []

    world
    |> cast(params, permitted)
  end
end
