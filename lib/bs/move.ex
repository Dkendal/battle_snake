defmodule Bs.Move do
  alias __MODULE__
  alias Bs.Point

  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field(:move, :string, default: "up")
    field(:taunt, :string)
    field(:snake_id, :string)
  end

  @up %Point{x: 0, y: -1}
  def up, do: @up

  @down %Point{x: 0, y: 1}
  def down, do: @down

  @right %Point{x: 1, y: 0}
  def right, do: @right

  @left %Point{x: -1, y: 0}
  def left, do: @left

  def default_move(), do: %Move{move: "up"}

  def default_move(snake) do
    do_default_move(snake.coords)
  end

  defp do_default_move([v1, v2 | _]),
    do: Point.sub(v1, v2)
    |> from_point
    |> do_default_move

  defp do_default_move({:ok, move}), do: move

  defp do_default_move(:error), do: default_move()

  defp do_default_move(_), do: do_default_move(:error)

  def moves do
    [up(), down(), left(), right()]
  end

  def to_point(%Move{move: move}), do: to_point(move)

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

  @permitted [:move]
  @required [:move]
  @moves ["up", "down", "left", "right"]

  def changeset(model, params \\ %{})

  def changeset(model, params) do
    model
    |> cast(params, @permitted)
    |> validate_required(@required)
    |> validate_inclusion(:move, @moves)
  end
end
