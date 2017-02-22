defimpl Poison.Encoder, for: BattleSnake.Snake do
  def encode(snake, opts) do
    keys = [:coords, :id, :taunt, :health_points, :name] ++
      if Keyword.get(opts, :consumer) do  [ :head_url, :color] else [] end
    Poison.encode!(Map.take(snake, keys))
  end
end

defmodule BattleSnake.Snake do
  alias __MODULE__
  alias BattleSnake.{Point}

  @max_health_points 100

  @type health :: :ok | {:error, any}
  @type cause_of_death :: {atom, any}

  @type t :: %Snake{
    id: reference,
    color: String.t,
    coords: [Point.t],
    head_url: String.t,
    name: String.t,
    taunt: String.t,
    url: String.t,
    health: health,
    cause_of_death: cause_of_death,
  }

  defstruct [
    :id,
    :cause_of_death,
    :head_url,
    color: "",
    coords: [],
    name: "",
    taunt: "",
    url: "",
    health: {:error, :init},
    health_points: @max_health_points,
  ]

  @doc """
  Checks if the snake has collided with a wall or is outside the walls.

  Only checks the head, because it's the only part that moves.
  """
  def dead?(
    %{coords: [%{y: y, x: x} |_]},
    %{width: w, height: h})
  when not y in 0..(w-1)
  or not x in 0..(h-1),
    do: true

  def dead?(%{health_points: hp}, _)
  when hp <= 0,
    do: true

  @doc """
  Checks if the snake has collided with any one snake's body.
  """
  def dead?(snake, world) do
    head = hd snake.coords
    stream = Stream.flat_map(world.snakes, & tl(&1.coords))
    Enum.member? stream, head
  end

  def grow(snake, size) do
    update_in snake.coords, fn coords ->
      last = List.last coords
      new_segments = List.duplicate(last, size)
      coords ++ new_segments
    end
  end

  @doc "Reduce health points."
  @spec dec_health_points(t, pos_integer) :: t
  def dec_health_points(snake, amount \\ 1) do
    update_in(snake.health_points, & &1 - amount)
  end

  def len(snake) do
    length snake.coords
  end

  def head(snake) do
    hd body snake
  end

  def tail(snake) do
    tl body snake
  end

  def body(snake) do
    snake.coords
  end

  @doc "Set this snake's health_points to #{@max_health_points}"
  @spec reset_health_points(t) :: t
  def reset_health_points(snake) do
    put_in(snake.health_points, @max_health_points)
  end

  def resolve_head_to_head(snakes, acc \\ [])

  def resolve_head_to_head([], acc) do
    acc
  end

  def resolve_head_to_head(snakes, _acc) do
    snakes
    |> Enum.group_by(& hd(&1.coords))
    |> Enum.map(fn
       {_, [snake]} ->
         snake

       {_, snakes} ->
         snakes = snakes
         |> Enum.map(& {len(&1), &1})
         |> Enum.sort_by(& - elem(&1, 0))

         case snakes do
           [{size, _}, {size, _} | _] ->
             # one or more are the same size
             # all die
             nil
           [{_, snake} | _] ->
             snake
         end
    end) |> Enum.reject(& &1 == nil)
  end

  @doc """
  Update the snake by moving the snake's cooridinates by the vector "move".
  """
  @spec move(t, Point.t) :: t
  def move(snake, move) do
    body = body snake
    head = head snake
    body = List.delete_at(body, -1)
    body = [Point.add(head, move) | body]
    put_in(snake.coords, body)
  end
end
