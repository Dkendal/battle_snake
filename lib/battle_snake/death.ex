defmodule BattleSnake.Death do
  alias BattleSnake.World
  alias BattleSnake.Snake
  alias BattleSnake.World.DeathEvent

  @spec reap(World.t) :: World.t
  def reap(world) do
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
end
