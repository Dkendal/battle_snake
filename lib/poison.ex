defimpl Poison.Encoder, for: BattleSnake.World do
  def encode(world, opts) do
    attrs = [
      :food,
      :turn,
      :snakes,
    ]

    board = []

    map = %{
      board: board
    }

    map = world
    |> Map.take(attrs)
    |> Dict.merge(map)

    Poison.encode!(map, opts)
  end
end

defimpl Poison.Encoder, for: BattleSnake.Point do
  def encode(%{x: x, y: y}, opts) do
    Poison.encode!([x, y], opts)
  end
end

defimpl Poison.Encoder, for: BattleSnake.Snake do
  def encode(snake, opts) do
    attrs = [
      :url,
      :name,
      :coords
    ]

    map = %{
    }

    map = snake
    |> Map.take(attrs)
    |> Dict.merge(map)

    Poison.encode!(map, opts)
  end
end
