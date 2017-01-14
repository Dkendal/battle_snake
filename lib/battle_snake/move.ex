defmodule BattleSnake.Move do
  alias __MODULE__
  alias BattleSnake.Snake

  defstruct [:move, :taunt]

  @type direction :: String.t

  @type t :: %__MODULE__{
    move: direction,
    taunt: String.t,
  }

  @doc "collect all moves for living snakes"
  @spec all(list(Snake.t), (Snake.t -> Move.t)) :: list(Snake.t)
  def all(snakes, move_fn, timeout \\ 5000) do
    snakes
    |> Enum.map(fn snake ->
      Task.async(fn ->
        move_fn.(snake)
      end)
    end)
    |> Task.yield_many(timeout)
    |> Stream.map(fn {task, result} ->
      # Kill tasks that exceeded the timeout.
      result || Task.shutdown(task, :brutal_kill)
    end)
    |> Stream.map(fn
      nil ->
        # Task timed out
        default_move
      {:exit, _} ->
        # Task died
        default_move
      {:ok, value} ->
        value
    end)
    |> Enum.to_list
  end

  defp default_move do
    %Move{
      move: "up"
    }
  end
end
