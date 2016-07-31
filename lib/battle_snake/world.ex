defmodule BattleSnake.World do
  alias BattleSnake.{Snake, Board, Point, World}

  defstruct [
    food: [],
    snakes: [],
    dead_snakes: [],
    max_food: 2,
    height: 0,
    width: 0,
  ]

  @size 4
  @max_food 1
  @draw_frames 1
  @turn_delay 100
  @clear false

  def up,     do: [0, -1]
  def down,   do: [0,  1]
  def right,  do: [1,  0]
  def left,   do: [-1,  0]

  def moves do
    [
      up,
      down,
      left,
      right,
    ]
  end

  def convert(direction) do
    case direction do
      "up" -> up
      "down" -> down
      "left" -> left
      "right" -> right
    end
  end

  def tick(%{"snakes" => []} = world, previous) do
    :ok
  end

  def tick(world), do: tick(world, world)

  def stock_food(world) do
    f = fn (_i, world) ->
      add_food = & [rand_unoccupied_space(world) | &1]
      update_in(world.food, add_food)
    end

    n = world.max_food - length(world.food)

    times(n)
    |> Enum.reduce(world, f)
  end

  def replace_eaten_food world do
    world
    |> remove_eaten_food
    |> stock_food
  end

  def rand_unoccupied_space(world) do
    h = world.height - 1
    w = world.width - 1
    snakes = get_in(world.snakes, [Access.all, :coords])
    food = world.food

    open_spaces = for y <- 0..h, x <- 0..w,
      not %Point{y: y, x: x} in snakes,
      not %Point{y: y, x: x} in food,
      do: %Point{y: y, x: x}

    Enum.random open_spaces
  end

  def step(world) do
    world
    |> clean_up_dead
    |> grow_snakes
    |> remove_eaten_food
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

    snakes = Snake.resolve_head_to_head(acc.live)
    dead = acc.live -- snakes
    world = update_in(world.dead_snakes, & &1 ++ dead)

    put_in(world.snakes, snakes)
  end

  def grow_snakes world do
    world = update_in world["snakes"], fn snakes ->
      for snake <- snakes do
        increase = grew(world, snake)
        Snake.grow(snake, increase)
      end
    end
  end

  def remove_eaten_food(world) do
    update_in world["food"], fn food ->
      Enum.reject food, &eaten?(world, &1)
    end
  end

  def eaten?(world, apple) do
    Enum.any? world["snakes"], fn
      %{"coords" => [^apple | _]} ->
        true
      _ ->
        false
    end
  end


  def grew(world, snake) do
    head = hd snake["coords"]

    if head in world["food"] do
      1
    else
      0
    end
  end

  def apply_moves world, moves do
    update_in world["snakes"], fn snakes ->
      for snake <- snakes do
        name = snake["name"]
        direction = get_in moves, [name]
        move = convert(direction)
        Snake.move(snake, move)
      end
    end
  end

  defp times(n) when n <= 0, do: []

  defp times(n) do
    Stream.iterate(0, &(&1+1))
    |> Stream.take(n)
  end
end
