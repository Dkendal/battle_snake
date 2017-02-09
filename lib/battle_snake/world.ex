defmodule BattleSnake.World do
  use Mnesia.Repo

  alias BattleSnake.{
    Move,
    Point,
    Snake,
    Point}

  defmodule DeathEvent do
    defstruct [:turn, :snake]
  end

  @type t :: %__MODULE__{
    id: any,
    food: [Point.t],
    snakes: [Snake.t],
    dead_snakes: [any],
    max_food: pos_integer,
    height: pos_integer,
    width: pos_integer,
    turn: pos_integer,
    moves: %{String.t => Move.t},
    game_id: pos_integer,
  }

  defstruct [
    :id,
    :game_form_id,
    :created_at,
    food: [],
    snakes: [],
    dead_snakes: [],
    max_food: 2,
    height: 10,
    width: 10,
    turn: 0,
    moves: %{},
    deaths: [],
    game_id: 0,
  ]

  def fields,
    do: [:id,
         :created_at,
         :food,
         :snakes,
         :dead_snakes,
         :game_form_id,
         :max_food,
         :height,
         :width,
         :turn,
         :deaths]


  def up,     do: %Point{x: 0,  y: -1}
  def down,   do: %Point{x: 0,  y: 1}
  def right,  do: %Point{x: 1,  y: 0}
  def left,   do: %Point{x: -1, y: 0}

  def moves do
    [
      up(),
      down(),
      left(),
      right(),
    ]
  end

  def convert(direction) do
    case direction do
      "up" -> up()
      "down" -> down()
      "left" -> left()
      "right" -> right()
    end
  end

  def stock_food(world) do
    f = fn (_i, world) ->
      add_food = & [rand_unoccupied_space(world) | &1]
      update_in(world.food, add_food)
    end

    n = world.max_food - length(world.food)

    times(n)
    |> Enum.reduce(world, f)
  end

  # @spec rand_unoccupied_space(t) :: any
  def rand_unoccupied_space(world) do
    h = world.height - 1
    w = world.width - 1
    snakes = Enum.flat_map world.snakes, & &1.coords
    food = world.food

    open_spaces = for y <- 0..h, x <- 0..w,
      not %Point{y: y, x: x} in snakes,
      not %Point{y: y, x: x} in food,
      do: %Point{y: y, x: x}

    Enum.random open_spaces
  end

  @doc "increase world.turn by 1"
  def inc_turn(world) do
    update_in(world.turn, &(&1+1))
  end

  def step(world) do
    world
    |> BattleSnake.WorldMovement.next
    |> inc_turn
    |> clean_up_dead
    |> dec_health_points
    |> grow_snakes
    |> remove_eaten_food
    |> stock_food
  end


  @doc "Reduce all snakes health points by 1"
  @spec dec_health_points(t) :: t
  def dec_health_points(world) do
    update_in world.snakes, fn snakes ->
      Enum.map(snakes, &Snake.dec_health_points/1)
    end
  end

  def clean_up_dead world do
    snakes = world.snakes

    acc = %{live: [], dead: []}

    acc = Enum.reduce snakes, acc, fn snake, acc ->
      f = &[snake |&1]
      if Snake.dead?(snake, world) do
        update_in(acc.dead, f)
      else
        update_in(acc.live, f)
      end
    end

    world = put_in(world.snakes, acc.live)
    world = update_in(world.dead_snakes, & &1 ++ acc.dead)

    living_snakes = Snake.resolve_head_to_head(acc.live)
    head_to_head_dead = acc.live -- living_snakes

    world = update_in(world.dead_snakes, & &1 ++ head_to_head_dead)

    world = update_in(world.deaths, fn deaths ->
      dead = acc.dead ++ head_to_head_dead
      for snake <- dead, do: %DeathEvent{turn: world.turn, snake: snake}
    end)

    put_in(world.snakes, living_snakes)
  end

  @spec grow_snakes(t) :: t
  def grow_snakes(world) do
    update_in world.snakes, fn snakes ->
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
    end
  end

  def remove_eaten_food(world) do
    update_in world.food, fn food ->
      Enum.reject food, &eaten?(world, &1)
    end
  end

  def eaten?(world, apple) do
    Enum.any? world.snakes, fn
      %{coords: [^apple | _]} ->
        true
      _ ->
        false
    end
  end

  def grew(world, snake) do
    head = hd snake.coords

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

  defp times(n) when n <= 0, do: []

  defp times(n) do
    Stream.iterate(0, &(&1+1))
    |> Stream.take(n)
  end
end

defimpl Poison.Encoder, for: BattleSnake.World do
  def encode(world, opts) do
    me = Keyword.get(opts, :me)

    attrs = [
      :food,
      :turn,
      :snakes,
      :width,
      :height,
      :game_id,
    ]

    map = Map.take(world, attrs)

    map = if me do
      Map.put(map, "you", me)
    else
      map
    end

    Poison.encode!(map, opts)
  end
end
