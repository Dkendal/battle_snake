defmodule BattleSnake.Point do
  @type t :: %__MODULE__{
    x: integer,
    y: integer,
  }

  defstruct [:x, :y]

  defmacro __using__(_) do
    quote do
      require BattleSnake.Point
      import BattleSnake.Point, only: :macros
    end
  end

  defmacro p(x, y),
    do: quote do: %BattleSnake.Point{
          x: unquote(x),
          y: unquote(y)}

  @spec sub(t, t) :: t
  def sub(a, b) do
    %__MODULE__{
      y: a.y - b.y,
      x: a.x - b.x,
    }
  end

  @doc "Scalar addition of a vector"
  @spec add(t, number) :: t
  def add(a, b) when is_number(b) do
    add(a, p(b, b))
  end

  @doc "Add two vectors"
  @spec add(t, t) :: t
  def add(a, b) do
    %__MODULE__{
      y: a.y + b.y,
      x: a.x + b.x,
    }
  end

  @doc "Scalar multiplication of a vector"
  @spec mul(t, number) :: t
  def mul(v, s) when is_number(s) do
    p(v.x * s, v.y * s)
  end

  @spec line(t, t, pos_integer) :: [t]
  def line(from, dir, length) do
    Stream.iterate(from, &add(&1, dir))
    |> Enum.take(length)
  end
end

defimpl Poison.Encoder, for: BattleSnake.Point do
  def encode(%{x: x, y: y}, opts) do
    Poison.encode!([x, y], opts)
  end
end
