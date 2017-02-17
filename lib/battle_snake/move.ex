defmodule BattleSnake.Move do
  alias __MODULE__

  alias BattleSnake.{
    World,
    Point,
    Snake,
  }

  defstruct [
    :move,
    :taunt,
    :snake_id,
    __meta__: %Move.Meta{}
  ]

  @type direction :: String.t
  @type t :: %__MODULE__{
    move: direction,
    taunt: String.t,
    snake_id: reference
  }

  @spec up() :: Point.t
  def up, do: %Point{x: 0, y: -1}

  @spec down() :: Point.t
  def down, do: %Point{x: 0, y: 1}

  @spec right() :: Point.t
  def right, do: %Point{x: 1, y: 0}

  @spec left() :: Point.t
  def left, do: %Point{x: -1, y: 0}

  @spec default_move() :: Point.t
  def default_move(), do: %Move{move: "up"}

  @spec moves() :: [Point.t]
  def moves do
    [
      up(),
      down(),
      left(),
      right(),
    ]
  end

  @spec to_point(t) :: Point.t
  def to_point(%Move{move: move}),
    do: to_point(move)

  @spec to_point(binary) :: Point.t
  def to_point(move) when is_binary(move) do
    case move do
      "up" -> up()
      "down" -> down()
      "left" -> left()
      "right" -> right()
    end
  end
end
