defmodule Bs.Point do
  use Ecto.Schema

  @primary_key false

  embedded_schema do
    field(:x, :integer)
    field(:y, :integer)
  end

  defmacro __using__(_) do
    quote do
      require Bs.Point
      import Bs.Point, only: :macros
    end
  end

  defmacro p(x, y), do: quote(do: %Bs.Point{x: unquote(x), y: unquote(y)})

  def sub(a, b) do
    %__MODULE__{y: a.y - b.y, x: a.x - b.x}
  end

  @doc "Scalar addition of a vector"
  def add(a, b) when is_number(b) do
    add(a, p(b, b))
  end

  @doc "Add two vectors"
  def add(a, b) do
    %__MODULE__{y: a.y + b.y, x: a.x + b.x}
  end

  @doc "Scalar multiplication of a vector"
  def mul(v, s) when is_number(s) do
    p(v.x * s, v.y * s)
  end

  @doc "Scalar division of a vector"
  def div(v, s) when is_number(s) do
    p(v.x / s, v.y / s)
  end

  def mag(p), do: magnitude(p)

  def magnitude(p(0, y)) do
    abs(y)
  end

  def magnitude(p(x, 0)) do
    abs(x)
  end

  def magnitude(p(x, y)) do
    :math.sqrt(x * x + y * y)
  end

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
