defmodule Snek.Server do
  alias Snek.{World, Snake}

  import Snek.World

  @size 4
  @max_food 1
  @draw_frames 1
  @turn_delay 100
  @clear false

  def tick(%{"snakes" => []} = state, previous) do
    :ok
  end

  def tick(state), do: tick(state, state)

  def init_food state, max do
    Enum.reduce 1..max, state, fn _, state ->
      update_in state["food"], fn food ->
        [rand_unoccupied_space(state) | food]
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

  def rand_unoccupied_space(state) do
    snakes = Enum.flat_map state["snakes"], & &1["coords"]
    food = state["food"]
    rand_unoccupied_space(snakes, food)
  end

  def rand_unoccupied_space(snakes, food) do
    x = :rand.uniform(20) - 1
    y = :rand.uniform(20) - 1

    new_pos = [x, y]

    if not new_pos in snakes and not new_pos in food do
      new_pos
    else
      rand_unoccupied_space(snakes, food)
    end
  end
end
