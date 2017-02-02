defmodule BattleSnake.MnesiaStrategy do
  use ExMachina.Strategy, function_name: :create

  def handle_create(record, _opts) do
    Mnesia.Repo.save(record)
  end
end

defmodule BattleSnake.Factory do
  use ExMachina
  use BattleSnake.MnesiaStrategy
  use BattleSnake.Point

  def world_factory do
    %BattleSnake.World{
    }
  end

  def with_food_on_snake(world: world, snake: snake) do
    update_in world.food, fn rest ->
      food = hd(snake.coords)
      [food|rest]
    end
  end

  def snake_factory do
    %BattleSnake.Snake{}
  end

  def with_snake_in_world(snake: snake, world: world, length: length) do
    point = BattleSnake.World.rand_unoccupied_space(world)
    snake = put_in(snake.coords, List.duplicate(point, length))
    world = update_in(world.snakes, & [snake|&1])
    [snake: snake, world: world]
  end

  def with_starvation(snake) do
    put_in(snake.health_points, 0)
  end

  def state_factory do
    %BattleSnake.GameServer.State{
      world: build(:world)
    }
  end

  def game_form_factory do
    %BattleSnake.GameForm{
    }
  end
end
