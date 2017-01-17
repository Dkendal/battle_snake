defmodule BattleSnake.WorldMovement do
  alias BattleSnake.{World, Move, Point, Snake}

  @api Application.get_env(:battle_snake, :snake_api)

  @moduledoc """
  Applies movement updates to the world.
  """

  @doc """
  Apply list of moves to world, updating the coordinates of all snakes.
  """
  @spec apply(World.t, [Move.t]) :: World.t
  def apply(world, moves) do
    grouped_moves = Enum.group_by(moves, & &1.snake.name)

    world = update_in(world.snakes, fn snakes ->
      for snake <- snakes do
        [move] = grouped_moves[snake.name]
        point = World.convert(move.move)
        Snake.move(snake, point)
      end
    end)

    put_in(world.moves, moves)
  end

  @doc "Contact all clients and update the world state with their move."
  @spec next(World.t) :: World.t
  def next(world) do
    moves = BattleSnake.Move.all(world, &@api.move/2)
    BattleSnake.WorldMovement.apply(world, moves)
  end
end
