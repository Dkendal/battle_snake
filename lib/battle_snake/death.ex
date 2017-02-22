defmodule BattleSnake.Death do
  alias BattleSnake.World
  alias BattleSnake.Snake
  alias BattleSnake.GameServer.State
  alias BattleSnake.World.DeathEvent

  use BattleSnake.Point

  @type state :: State.t

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

    living_snakes = Snake.resolve_head_to_head(acc.live)
    head_to_head_dead = acc.live -- living_snakes

    world = update_in(world.dead_snakes, & &1 ++ head_to_head_dead)

    world = update_in(world.deaths, fn _deaths ->
      dead = acc.dead ++ head_to_head_dead
      for snake <- dead, do: %DeathEvent{turn: world.turn, snake: snake}
    end)

    put_in(world.snakes, living_snakes)
  end

  @doc "Kill all snakes that starved this turn"
  @spec starvation(state) :: state
  def starvation(state) do
    {living, dead} = do_starvation(state.world.snakes)
    state = put_in(state.world.snakes, living)
    update_in(state.world.dead_snakes, &(dead ++ &1))
  end

  def do_starvation(snakes, acc \\ {[], []})

  def do_starvation([], acc) do
    acc
  end

  def do_starvation([%{health_points: hp} = snake|rest], {living, dead})
  when hp <= 0 do
    reason = {:starvation, []}
    snake = put_in(snake.cause_of_death, reason)
    do_starvation(rest, {living, [snake|dead]})
  end

  def do_starvation([snake|rest], {living, dead}) do
    do_starvation(rest, {[snake|living], dead})
  end

  @doc "Kills all snakes that hit a wall"
  @spec wall_collision(state) :: state
  def wall_collision(state) do
    dim = {state.world.width, state.world.height}
    {living, dead} = do_wall_collision(state.world.snakes, dim)
    state = put_in(state.world.snakes, living)
    update_in(state.world.dead_snakes, &(dead ++ &1))
  end

  def do_wall_collision(snakes, dim, acc \\ {[], []})

  def do_wall_collision([], _dim, acc) do
    acc
  end

  def do_wall_collision([%{coords: [p(x, y)|_]} = snake|rest], {w, h}, {living, dead})
  when not y in 0..(w-1)
  or not x in 0..(h-1) do
    reason = {:wall_collision, []}
    snake = put_in(snake.cause_of_death, reason)
    do_wall_collision(rest, {w, h}, {living, [snake|dead]})
  end

  def do_wall_collision([snake|rest], {w, h}, {living, dead}) do
    do_wall_collision(rest, {w, h}, {[snake|living], dead})
  end

  @doc "Kill all snakes that crashed into a body"
  def body_collision do
  end

  @doc "Kill all snakes that died in a head on collision"
  def head_collision do
  end
end
