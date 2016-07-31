defmodule BattleSnake.World.Map do
  alias BattleSnake.{Board}

  # set the :snake_map index
  def put_snakes_in_map world do
    snake_map = Enum.reduce world["snakes"], %{}, fn snake, acc ->
      name = snake["name"]
      put_in acc[name], snake
    end

    world = put_in world[:snake_map], snake_map
  end

  def set_objects world do
    build_snake_map build_map world
  end

  def delete_map world do
    put_in world[:map], %{}
  end

  def put_food_in_map world do
    Enum.reduce world["food"], world, fn [x, y], world ->
      put_in world, path(x, y), Board.food
    end
  end

  # sets the :map on the game
  def build_map world do
    put_snakes_in_map put_food_in_map delete_map world
  end

  def build_snake_map world do
    Enum.reduce world["snakes"], world, fn snake, world ->
      name = snake["name"]
      head_obj = %{"world" => "head", name => name}
      body_obj = %{"world" => "body", name => name}

      [[x, y] | body] = Enum.uniq snake["coords"]

      world = put_in world, path(x, y), head_obj

      Enum.reduce body, world, fn [x, y], world ->
        put_in world, path(x, y), body_obj
      end
    end
  end

  def path(x, y) do
    [
      Access.key(:map, %{}),
      Access.key(x, %{}),
      Access.key(y, %{}),
    ]
  end
end
