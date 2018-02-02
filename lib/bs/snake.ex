defmodule Bs.Snake do
  defmodule Status do
    defstruct [:type, :data]
    def alive, do: %Status{type: :alive}
    def connection_failure(), do: %Status{type: :connection_failure}
    def dead(death), do: %Status{type: :dead, data: death}
  end

  alias Bs.Move
  alias Bs.Point
  import Ecto.Changeset
  use Ecto.Schema

  @max_health_points 100
  @heads Bs.Const.heads()
  @tails Bs.Const.tails()

  embedded_schema do
    embeds_many(:coords, Point)
    embeds_one(:status, Status)
    field(:color, :string, default: "black")
    # TODO deprecated
    field(:death, :string)
    field(:head_type, :string, default: "regular")
    field(:head_url, :string)
    field(:health_points, :string, default: @max_health_points)
    field(:name, :string, default: "")
    field(:secondary_color, :string)
    field(:tail_type, :string, default: "regular")
    field(:taunt, :string, default: "")
    field(:url, :string, default: "")
  end

  def changeset(model, params \\ %{})

  def changeset(model, params) do
    permitted = [
      :color,
      :head_type,
      :head_url,
      :name,
      :secondary_color,
      :tail_type,
      :taunt,
      :url
    ]

    required = [:name]

    model
    |> cast(params, permitted)
    |> validate_required(required)
    |> validate_inclusion(:head_type, @heads)
    |> validate_inclusion(:tail_type, @tails)
  end

  @doc """
  Checks if the snake has collided with a wall or is outside the walls.

  Only checks the head, because it's the only part that moves.
  """
  def dead?(%{coords: [%{y: y, x: x} | _]}, %{width: w, height: h})
      when y not in 0..(w - 1) or x not in 0..(h - 1) do
    true
  end

  def dead?(%{health_points: hp}, _) when hp <= 0 do
    true
  end

  @doc """
  Checks if the snake has collided with any one snake's body.
  """
  def dead?(snake, world) do
    head = hd(snake.coords)
    stream = Stream.flat_map(world.snakes, &tl(&1.coords))
    Enum.member?(stream, head)
  end

  def grow(snake, size) do
    update_in(snake.coords, fn coords ->
      last = List.last(coords)
      new_segments = List.duplicate(last, size)
      coords ++ new_segments
    end)
  end

  @doc "Reduce health points."
  def dec_health_points(snake, amount \\ 1) do
    update_in(snake.health_points, &(&1 - amount))
  end

  def len(snake) do
    length(snake.coords)
  end

  def head(snake) do
    hd(body(snake))
  end

  def tail(snake) do
    tl(body(snake))
  end

  def body(snake) do
    snake.coords
  end

  @doc "Set this snake's health_points to #{@max_health_points}"
  def reset_health_points(snake) do
    put_in(snake.health_points, @max_health_points)
  end

  def resolve_head_to_head(snakes, acc \\ [])

  def resolve_head_to_head([], acc) do
    acc
  end

  def resolve_head_to_head(snakes, _acc) do
    snakes
    |> Enum.group_by(&hd(&1.coords))
    |> Enum.map(fn
      {_, [snake]} ->
        snake

      {_, snakes} ->
        snakes =
          snakes
          |> Enum.map(&{len(&1), &1})
          |> Enum.sort_by(&(-elem(&1, 0)))

        case snakes do
          [{size, _}, {size, _} | _] ->
            # one or more are the same size
            # all die
            nil

          [{_, snake} | _] ->
            snake
        end
    end)
    |> Enum.reject(&(&1 == nil))
  end

  def move(snake, %Move{} = move) do
    snake = put_in(snake.taunt, move.taunt)
    move(snake, Move.to_point(move))
  end

  @doc """
  Update the snake by moving the snake's cooridinates by the vector "move".
  """
  def move(%{coords: []}, _) do
    raise "Snake can't move, it has no body segments."
  end

  def move(snake, %Point{} = point) do
    body = body(snake)
    head = head(snake)
    body = List.delete_at(body, -1)
    body = [Point.add(head, point) | body]
    put_in(snake.coords, body)
  end

  def died_on(snake) do
    case snake.status do
      %{type: :dead, data: %{turn: turn}} -> {:ok, turn}
      _ -> {:error, :alive}
    end
  end

  def dead!(model, death) do
    # TODO deprecated
    model = %{model | death: death}
    %{model | status: Status.dead(death)}
  end

  def alive?(model) do
    model.status.type == :alive
  end

  def alive!(model) do
    %{model | status: Status.alive()}
  end

  def connection_failure!(model) do
    %{model | status: Status.connection_failure()}
  end

  defdelegate(fetch(snake, key), to: Map)
end

defimpl Poison.Encoder, for: Bs.Snake do
  def encode(snake, opts) do
    keys = [:coords, :id, :taunt, :health_points, :name]

    snake
    |> Map.take(keys)
    |> Poison.encode!(opts)
  end
end
