defmodule BattleSnake.Move do
  @type direction :: String.t

  @type t :: %__MODULE__{
    move: direction,
    taunt: String.t,
  }

  defstruct [:move, :taunt]
end
