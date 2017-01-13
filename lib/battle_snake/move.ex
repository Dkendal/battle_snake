defmodule BattleSnake.Move do
  alias __MODULE__
  alias BattleSnake.Snake

  @type direction :: String.t

  @type t :: %__MODULE__{
    move: direction,
    taunt: String.t,
  }

  defstruct [:move, :taunt]

  @doc "collect all moves for living snakes"
  @spec all(list(Snake.t), (Snake.t -> Move.t)) :: list(Snake.t)
  def all(snakes, move_fn) do
    snakes
    |> Task.async_stream(fn snake ->
      move_fn.(snake)
    end)
    |> Enum.into([], fn {:ok, move} ->
        move
    end)
  end
end
