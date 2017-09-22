defmodule Bs.Point do
  @type t :: %__MODULE__{
    x: integer,
    y: integer,
  }

  defstruct [:x, :y]

  defmacro __using__(_) do
    quote do
      require Bs.Point
      import Bs.Point, only: :macros
    end
  end

  defmacro p(x, y),
    do: quote do: %Bs.Point{
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

  @doc "Scalar division of a vector"
  @spec mul(t, number) :: t
  def div(v, s) when is_number(s) do
    p(v.x / s, v.y / s)
  end

  @spec mag(t) :: non_neg_integer
  def mag(p), do: magnitude(p)

  @spec magnitude(t) :: non_neg_integer
  def magnitude(p(0, y)) do
    abs y
  end

  def magnitude(p(x, 0)) do
    abs x
  end

  def magnitude(p(x, y)) do
    :math.sqrt(x * x + y * y)
  end

  @spec line(t, t, pos_integer) :: [t]
  def line(from, dir, magnitude) do
    Stream.iterate(from, &add(&1, dir))
    |> Enum.take(magnitude)
  end
end

defimpl Poison.Encoder, for: Bs.Point do
  def encode(%{x: x, y: y}, opts) do
    Poison.encode!([x, y], opts)
  end
end
