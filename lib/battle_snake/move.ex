defmodule BattleSnake.Move do
  alias __MODULE__
  alias BattleSnake.{World, Snake}

  defstruct [:move, :taunt, :snake]

  @type direction :: String.t

  @type t :: %__MODULE__{
    move: direction,
    snake: Snake.t,
    taunt: String.t,
  }

  @doc """
  Collects all moves for all living snakes for world.

  For each snake in world.snakes, a linked task is started, which in turn
  starts an unlinked task when performs the actual request.

  When the requesting task times-out it is killed, and the default move is
  reported back to the supervising task which is then aggregated with the
  other results.
  """
  @shortdoc "collect all moves for living snakes"
  @spec all(World.t, ((Snake.t, World.t) -> Move.t)) :: [Snake.t]
  def all(world, request_fun, timeout \\ 200) do
    snakes = world.snakes

    do_task =
    fn (snake) ->
      {:ok, sup_pid} = Task.Supervisor.start_link()

      task = Task.Supervisor.async_nolink(
        sup_pid,
        fn -> request_fun.(snake, world) end)

      move =
        case Task.yield(task, timeout) || Task.shutdown(task) do
          {:ok, move} ->
            move
          nil ->
            default_move
        end

      # identify what snake this move belongs to.
      put_in(move.snake, snake)
    end

    # The async stream shouldn't fail to respond.
    # we're timing idividual tasks above.
    snakes
    |> Task.async_stream(do_task, timeout: :infinity)
    |> Enum.into([], fn {:ok, value} -> value end)
  end

  defp default_move do
    %Move{
      move: "up"
    }
  end
end
