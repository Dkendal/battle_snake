defmodule Bs.Test.Vector do
  alias Bs.Point

  use Ecto.Schema

  @primary_key false

  embedded_schema do
    field(:x, :integer)
    field(:y, :integer)
  end

  defmacro v(x, y) do
    quote bind_quoted: [x: x, y: y], do: %Bs.Test.Vector{
      x: x,
      y: y
    }
  end

  def to_point(vector) do
    %Point{
      x: vector.x,
      y: vector.y
    }
  end
end
