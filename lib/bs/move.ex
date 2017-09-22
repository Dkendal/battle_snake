defmodule Bs.Move do
  alias __MODULE__
  alias Bs.Point

  defstruct [
    :move,
    :taunt,
    :snake_id,
  ]

  @type direction :: String.t
  @type t :: %__MODULE__{
    move: direction,
    taunt: String.t,
    snake_id: reference
  }

  @up %Point{x: 0, y: -1}
  @spec up() :: Point.t
  def up, do: @up

  @down %Point{x: 0, y: 1}
  @spec down() :: Point.t
  def down, do: @down

  @right %Point{x: 1, y: 0}
  @spec right() :: Point.t
  def right, do: @right

  @left %Point{x: -1, y: 0}
  @spec left() :: Point.t
  def left, do: @left

  @spec default_move() :: Point.t
  def default_move(), do: %Move{move: "up"}

  def default_move(snake) do
    do_default_move(snake.coords)
  end

  defp do_default_move([v1, v2 | _]),
    do: Point.sub(v1, v2)
    |> from_point
    |> do_default_move

  defp do_default_move({:ok, move}),
    do: move

  defp do_default_move(:error),
    do: default_move()

  defp do_default_move(_),
    do: do_default_move(:error)

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

  def from_point(point) do
    case point do
      @up ->
        {:ok, %Move{move: "up"}}
      @down ->
        {:ok, %Move{move: "down"}}
      @left ->
        {:ok, %Move{move: "left"}}
      @right ->
        {:ok, %Move{move: "right"}}
      _ ->
        :error
    end
  end
end
