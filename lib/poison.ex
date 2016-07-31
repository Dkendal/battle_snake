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
