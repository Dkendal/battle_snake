defimpl Poison.Encoder, for: BattleSnake.World do
  alias BattleSnake.{Board, Point}

  def encode(world, opts) do
    attrs = [
      :food,
      :turn,
      :snakes,
    ]

    board = board(world)

    map = %{
      board: board
    }

    map = world
    |> Map.take(attrs)
    |> Dict.merge(map)

    Poison.encode!(map, opts)
  end

  def board(world) do
    rows = 0..(world.height - 1)
    cols = 0..(world.width - 1)

    add = fn board, p, value ->
      Map.put board, p, value
    end

    board = %{}

    f = fn p, board ->
      add.(board, p, Board.food)
    end

    board = Enum.reduce world.food, board, f

    for x <- cols do
      for y <- rows do
        p = %Point{x: x, y: y}
        case board[p] do
          nil ->
            Board.empty
          value ->
            value
        end
      end
    end
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
