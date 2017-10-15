defmodule Bs.Death do
  alias Bs.GameState
  alias Bs.Death.Collision
  alias Bs.Point
  alias Bs.Snake
  alias __MODULE__
  use Point

  defstruct [:turn, :causes]
  defmodule(Kill, do: defstruct([:turn, :with, :cause]))

  defmodule(BodyCollisionCause, do: defstruct([:with]))
  defmodule(Cause, do: defstruct([]))
  defmodule(HeadCollisionCause, do: defstruct([:with]))
  defmodule(SelfCollisionCause, do: defstruct([]))
  defmodule(StarvationCause, do: defstruct([]))
  defmodule(WallCollisionCause, do: defstruct([]))

  def combine_live(l) do
    l
    |> Stream.map(&MapSet.new/1)
    |> Enum.reduce(&MapSet.intersection/2)
    |> MapSet.to_list()
  end

  def combine_dead(l, turn) do
    l
    |> Enum.flat_map(& &1)
    |> do_combine_dead(turn, %{})
  end

  defp do_combine_dead([], turn, acc) do
    to_death = fn snake ->
      causes = snake.cause_of_death

      death = %Death{
        turn: turn,
        causes: causes
      }

      put_in(snake.cause_of_death, death)
    end

    acc
    |> Map.values()
    |> Enum.map(to_death)
  end

  defp do_combine_dead([snake | rest], turn, acc) do
    acc = update_dead_snake(snake, acc)
    do_combine_dead(rest, turn, acc)
  end

  defp update_dead_snake(%Snake{} = snake, acc) do
    cause = snake.cause_of_death
    merge_cause = &(cause ++ &1)
    update_snake = &update_in(&1.cause_of_death, merge_cause)
    Map.update(acc, snake.id, snake, update_snake)
  end

  def reap(%GameState{} = state) do
    world = state.world
    turn = world.turn
    dim = {world.width, world.height}

    snakes = state.world.snakes

    {l1, d1} = starvation(snakes)
    {l2, d2} = wall_collision(snakes, dim)
    {l3, d3} = collision(snakes)

    live = combine_live([l1, l2, l3])
    dead = combine_dead([d1, d2, d3], turn)

    world = put_in(world.snakes, live)
    world = update_in(world.dead_snakes, &(dead ++ &1))
    put_in(state.world, world)
  end

  @doc "Kill all snakes that starved this turn"
  def starvation(snakes) do
    {live, dead} = do_starvation(snakes)
    {live, dead}
  end

  def do_starvation(snakes, acc \\ {[], []})

  def do_starvation([], acc) do
    acc
  end

  def do_starvation([%{health_points: hp} = snake | rest], {live, dead})
      when hp <= 0 do
    reason = [%StarvationCause{}]
    snake = put_in(snake.cause_of_death, reason)
    do_starvation(rest, {live, [snake | dead]})
  end

  def do_starvation([snake | rest], {live, dead}) do
    do_starvation(rest, {[snake | live], dead})
  end

  @doc "Kills all snakes that hit a wall"
  def wall_collision(snakes, dim) do
    do_wall_collision(snakes, dim)
  end

  def do_wall_collision(snakes, dim, acc \\ {[], []})

  def do_wall_collision([], _dim, acc) do
    acc
  end

  def do_wall_collision([%{coords: [p(x, y) | _]} = snake | rest], {w, h}, {
        live,
        dead
      })
      when x not in 0..(w - 1) or y not in 0..(h - 1) do
    reason = [%WallCollisionCause{}]
    snake = put_in(snake.cause_of_death, reason)
    do_wall_collision(rest, {w, h}, {live, [snake | dead]})
  end

  def do_wall_collision([snake | rest], {w, h}, {live, dead}) do
    do_wall_collision(rest, {w, h}, {[snake | live], dead})
  end

  @doc "Kill all snakes that crashed into another snake"
  def collision(snakes) do
    tasks = Task.async_stream(snakes, Collision, :run, [snakes])

    results =
      tasks
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

  defp unzip_result({{:ok, reason}, snake}) do
    snake = put_in(snake.cause_of_death, reason)
    {:dead, snake}
  end

  defmodule Collision do
    def run(snake, snakes) do
      head = hd(snake.coords)

      Stream.map(snakes, fn other ->
        cond do
          other.id != snake.id and head == hd(other.coords) and
              length(snake.coords) <= length(other.coords) ->
            %HeadCollisionCause{with: other.id}

          other.id == snake.id and head in tl(other.coords) ->
            %SelfCollisionCause{}

          head in tl(other.coords) ->
            %BodyCollisionCause{with: other.id}

          true ->
            false
        end
      end)
      |> Stream.filter(& &1)
      |> Enum.to_list()
    end
  end
end
