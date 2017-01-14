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
    {:ok, sup_pid} = Task.Supervisor.start_link

    snakes
    |> Enum.map(fn snake ->
      Task.Supervisor.async_nolink(sup_pid, fn ->
        move_fn.(snake)
      end)
    end)
    |> Task.yield_many(timeout)
    |> Stream.map(&task_cleanup/1)
    |> Stream.map(&task_value/1)
    |> Enum.to_list
  end

  defp default_move do
    %Move{
      move: "up"
    }
  end

  defp task_value(value) do
    case(value) do
      nil ->
        # Timeout
        default_move

      {:exit, _} ->
        # Process died
        default_move

      {:ok, v} ->
        v
    end
  end

  defp task_cleanup({task, result}) do
    # Kill tasks that exceeded the timeout.
    result || Task.shutdown(task, :brutal_kill)
  end
end
