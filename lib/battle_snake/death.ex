defmodule BattleSnake.Death do
  alias BattleSnake.World
  alias BattleSnake.Snake
  alias BattleSnake.GameServer.State
  alias BattleSnake.World.DeathEvent

  use BattleSnake.Point

  @type width :: pos_integer
  @type height :: pos_integer
  @type dim :: {width, height}
  @type state :: State.t
  @type snake :: Snake.t
  @type live :: [snake]
  @type dead :: [snake]

  @spec reap(State.t) :: State.t
  def reap(%State{} = state) do
    %{state| world: reap(state.world)}
  end

  @spec reap(World.t) :: World.t
  def reap(%World{} = world) do
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

    live_snakes = Snake.resolve_head_to_head(acc.live)
    head_to_head_dead = acc.live -- live_snakes

    world = update_in(world.dead_snakes, & &1 ++ head_to_head_dead)

    world = update_in(world.deaths, fn _deaths ->
      dead = acc.dead ++ head_to_head_dead
      for snake <- dead, do: %DeathEvent{turn: world.turn, snake: snake}
    end)

    put_in(world.snakes, live_snakes)
  end

  @doc "Kill all snakes that starved this turn"
  @spec starvation([snake]) :: {live, dead}
  def starvation(snakes) do
    {live, dead} = do_starvation(snakes)
    {live, dead}
  end

  def do_starvation(snakes, acc \\ {[], []})

  def do_starvation([], acc) do
    acc
  end

  def do_starvation([%{health_points: hp} = snake|rest], {live, dead})
  when hp <= 0 do
    reason = {:starvation, []}
    snake = put_in(snake.cause_of_death, reason)
    do_starvation(rest, {live, [snake|dead]})
  end

  def do_starvation([snake|rest], {live, dead}) do
    do_starvation(rest, {[snake|live], dead})
  end

  @doc "Kills all snakes that hit a wall"
  @spec wall_collision([snake], dim) :: {live, dead}
  def wall_collision(snakes, dim) do
    do_wall_collision(snakes, dim)
  end

  def do_wall_collision(snakes, dim, acc \\ {[], []})

  def do_wall_collision([], _dim, acc) do
    acc
  end

  def do_wall_collision([%{coords: [p(x, y)|_]} = snake|rest], {w, h}, {live, dead})
  when not y in 0..(w-1)
  or not x in 0..(h-1) do
    reason = {:wall_collision, []}
    snake = put_in(snake.cause_of_death, reason)
    do_wall_collision(rest, {w, h}, {live, [snake|dead]})
  end

  def do_wall_collision([snake|rest], {w, h}, {live, dead}) do
    do_wall_collision(rest, {w, h}, {[snake|live], dead})
  end

  @doc "Kill all snakes that crashed into another snake"
  @spec collision([snake]) :: {live, dead}
  def collision(snakes) do
    tasks = Task.async_stream(
      snakes,
      BattleSnake.Death.Collision,
      :run,
      [snakes])

    results = tasks
    |> Stream.zip(snakes)
    |> Stream.map(&unzip_result/1)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))

    dead = Map.get(results, :dead, [])
    live = Map.get(results, :live, [])

    {live, dead}
  end

  defp unzip_result({{:ok, []}, snake}) do
    {:live, snake}
  end

  defp unzip_result({{:ok, collisions}, snake}) do
    reason = {:collision, collisions}
    snake = put_in(snake.cause_of_death, reason)
    {:dead, snake}
  end
end

defmodule BattleSnake.Death.Collision do
  def run(snake, snakes) do
    head = hd(snake.coords)

    Stream.map(snakes, fn other ->
      cond do
        other.id != snake.id and head == hd(other.coords) and length(snake.coords) <= length(other.coords) ->
          {:collision_head, other.id}

        head in tl(other.coords) ->
          {:collision_body, other.id}

        true ->
          false
      end
    end)
    |> Stream.filter(& &1)
    |> Enum.to_list
  end
end
