defimpl Poison.Encoder, for: BattleSnake.World do
  alias BattleSnake.{Board, World}

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
    |> Map.merge(map)

    Poison.encode!(map, opts)
  end

  def board(world) do
    add = fn board, p, value ->
      Map.put board, p, value
    end

    board = %{}

    f = fn p, board ->
      add.(board, p, Board.food)
    end

    board = Enum.reduce world.food, board, f

    board = Enum.reduce world.snakes, board, fn snake, board ->
      [head |body] = snake.coords

      board = Enum.reduce body, board, fn p, board ->
        value = %{
          "state" => "body",
          "snake" => snake.name,
        }

        Map.put board, p, value
      end

      value = %{
        "state" => "head",
        "snake" => snake.name,
      }

      Map.put board, head, value
    end

    World.map world, fn p ->
      case board[p] do
        nil ->
          Board.empty
        value ->
          value
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
    |> Map.merge(map)

    Poison.encode!(map, opts)
  end
end
