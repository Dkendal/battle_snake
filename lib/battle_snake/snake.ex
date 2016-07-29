defmodule BattleSnake.Snake do
  def new(params, rows, cols) do
    starting_pos = [:rand.uniform(rows), :rand.uniform(cols)]

    coords = (for _ <- 0..3, do: starting_pos)

    default = %{
      "color" => "",
      "coords" => coords,
      "head_url" => "",
      "name" => "",
      "taunt" => "",
      "url" => "",
    }

    Dict.merge default, params
  end

  def len(snake) do
    length snake["coords"]
  end

  def grow(snake, size) do
    update_in snake["coords"], fn coords ->
      last = List.last coords
      new_segments = for i <- 0..size, i > 0, do: last
      coords ++ new_segments
    end
  end

  def head_to_head(snakes, acc \\ [])

  def head_to_head([], acc) do
    acc
  end

  def head_to_head(snakes, acc) do
    snakes
    |> Enum.group_by(& hd(&1["coords"]))
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
end
