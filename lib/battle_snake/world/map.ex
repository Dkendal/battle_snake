defmodule BattleSnake.World.Map do
  alias BattleSnake.{Board}

  # set the :snake_map index
  def put_snakes_in_map state do
    snake_map = Enum.reduce state["snakes"], %{}, fn snake, acc ->
      name = snake["name"]
      put_in acc[name], snake
    end

    state = put_in state[:snake_map], snake_map
  end

  def set_objects state do
    build_snake_map build_map state
  end

  def delete_map state do
    put_in state[:map], %{}
  end

  def put_food_in_map state do
    Enum.reduce state["food"], state, fn [x, y], state ->
      put_in state, path(x, y), Board.food
    end
  end

  # sets the :map on the game
  def build_map state do
    put_snakes_in_map put_food_in_map delete_map state
  end

  def build_snake_map state do
    Enum.reduce state["snakes"], state, fn snake, state ->
      name = snake["name"]
      head_obj = %{"state" => "head", name => name}
      body_obj = %{"state" => "body", name => name}

      [[x, y] | body] = Enum.uniq snake["coords"]

      state = put_in state, path(x, y), head_obj

      Enum.reduce body, state, fn [x, y], state ->
        put_in state, path(x, y), body_obj
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
