defmodule BattleSnake.World do
  alias BattleSnake.{Snake, Board, Point, World}

  defstruct [
    :board,
    food: [],
    snakes: [],
    max_food: 0,
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


  def new(params, width: width, height: height) do
    board = Board.new(width, height)

    default = %{
      "snakes" => [],
      "food" => [],
      "board" => board
    }

    Dict.merge default, params
  end


  def tick(%{"snakes" => []} = state, previous) do
    :ok
  end

  def tick(state), do: tick(state, state)

  def init_food world do
    max = world.max_food
    Enum.reduce 1..max, world, fn _, world ->
      update_in world.food, fn food ->
        [rand_unoccupied_space(world) | food]
      end
    end
  end

  def add_new_food(state) do
    update_in state["food"], fn food ->
      new_food =
        for i <- 0..(@max_food - length(food)),
        i > 0,
        do: rand_unoccupied_space(state)

      food ++ new_food
    end
  end

  def replace_eaten_food state do
    state
    |> remove_eaten_food
    |> add_new_food
  end

  def rand_unoccupied_space(world) do
    h = world.height
    w = world.width
    snakes = get_in(world.snakes, [Access.all, :coords])
    food = world.food

    open_spaces = for y <- 0..h, x <- 0..w,
      not %Point{y: y, x: x} in snakes,
      not %Point{y: y, x: x} in food,
      do: %Point{y: y, x: x}

    Enum.random open_spaces
  end

  def step(state) do
    state
    |> clean_up_dead
    |> grow_snakes
    |> remove_eaten_food
  end

  def update_board state do
    state = World.Map.set_objects(state)
    max_y = state.rows - 1
    max_x = state.cols - 1

    board = for x <- 0..max_x do
      for y <- 0..max_y do
        case state[:map][x][y] do
          %{} = obj -> obj
          _ -> Board.empty
        end
      end
    end

    state = put_in state["board"], board
  end

  # wall collisions
  def dead?(%{rows: r, cols: c} = state, %{"coords" => [[x, y] |_]})
  when y in 0..(r - 1) and x in 0..(c - 1) do
    Enum.any? state["snakes"], fn %{"coords" => [_ | body]} ->
      Enum.member? body, [x, y]
    end
  end

  def dead?(_, _), do: true

  def clean_up_dead state do
    state = update_in state["snakes"], fn snakes ->
      snakes = Enum.reduce snakes, [], fn snake, snakes ->
        if dead?(state, snake) do
          snakes
        else
          [snake | snakes]
        end
      end

      Snake.head_to_head(snakes)
    end
  end

  def grow_snakes state do
    state = update_in state["snakes"], fn snakes ->
      for snake <- snakes do
        increase = grew(state, snake)
        Snake.grow(snake, increase)
      end
    end
  end

  def remove_eaten_food(state) do
    update_in state["food"], fn food ->
      Enum.reject food, &eaten?(state, &1)
    end
  end

  def eaten?(state, apple) do
    Enum.any? state["snakes"], fn
      %{"coords" => [^apple | _]} ->
        true
      _ ->
        false
    end
  end


  def grew(state, snake) do
    head = hd snake["coords"]

    if head in state["food"] do
      1
    else
      0
    end
  end

  def apply_moves state, moves do
    update_in state["snakes"], fn snakes ->
      for snake <- snakes do
        name = snake["name"]
        direction = get_in moves, [name]

        move(snake, direction)
      end
    end
  end

  def move(snake, direction) do
    [dx, dy] = case direction do
      "up" -> up
      "down" -> down
      "left" -> left
      "right" -> right
    end

    body = snake["coords"]

    [x, y] = hd(body)

    tail = List.delete_at(body, -1)

    new_coords = [[dx + x, dy + y]] ++ tail

    put_in snake["coords"], new_coords
  end

  def board(state) do
    state["board"]
  end
end
