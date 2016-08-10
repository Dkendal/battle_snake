defmodule BattleSnake.Snake do
  alias BattleSnake.{Point}

  defstruct [
    color: "",
    coords: [],
    head_url: "",
    name: "",
    taunt: "",
    url: "",
  ]

  def dead?(%{coords: [%{y: y, x: x} |_]}, %{width: w, height: h})
  when not y in 0..(w-1) or not x in 0..(h-1),
  do: true

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

  def resolve_head_to_head(snakes, acc \\ [])

  def resolve_head_to_head([], acc) do
    acc
  end

  def resolve_head_to_head(snakes, acc) do
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
           [{_, snake} | victims] ->
             growth = victims
             |> Enum.map(& elem(&1, 0))
             |> Enum.sum
             growth = round(growth / 2)
             grow(snake, growth)
         end
    end) |> Enum.reject(& &1 == nil)
  end

  def move(snake, move) do
    body = body snake
    head = head snake
    body = List.delete_at(body, -1)
    body = [Point.add(head, move) | body]
    put_in(snake.coords, body)
  end
end
