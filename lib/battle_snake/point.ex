defmodule BattleSnake.Point do
  defstruct [:x, :y]

  def sub(a, b) do
    %__MODULE__{
      y: a.y - b.y,
      x: a.x - b.x,
    }
  end

  def add(a, b) do
    %__MODULE__{
      y: a.y + b.y,
      x: a.x + b.x,
    }
  end
end
