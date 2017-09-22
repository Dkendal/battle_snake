defmodule Bs.MnesiaStrategy do
  use ExMachina.Strategy, function_name: :create

  def handle_create(record, _opts) do
    Mnesia.Repo.save(record)
  end
end

defmodule Bs.Factory do
  use ExMachina
  use Bs.MnesiaStrategy
  use Bs.Point

  defdelegate sequence(name), to: ExMachina

  def world_factory do
    %Bs.World{
      id: Ecto.UUID.generate(),
    }
  end

  def snake_form_factory do
    %BsWeb.SnakeForm{
      url: "example.com"
    }
  end

  def game_form_factory do
    %BsWeb.GameForm{
      id: Ecto.UUID.generate(),
      delay: 0,
    }
  end

  def with_food_on_snake(world: world, snake: snake) do
    update_in world.food, fn rest ->
      food = hd(snake.coords)
      [food|rest]
    end
  end

  def death_factory do
     %Bs.Death{
      turn: 0,
      causes: [%Bs.Death.StarvationCause{}]
    }
  end

  def snake_factory do
    %Bs.Snake{
      coords: [p(0, 0)]
    }
  end

  def kill_snake(snake, turn) do
    %{snake| cause_of_death: build(:death, turn: turn)}
  end

  def with_snake_in_world(snake: snake, world: world, length: length) do
    {:ok, point} = Bs.World.rand_unoccupied_space(world)
    snake = put_in(snake.coords, List.duplicate(point, length))
    world = update_in(world.snakes, & [snake|&1])
    [snake: snake, world: world]
  end

  def with_starvation(snake) do
    put_in(snake.health_points, 0)
  end

  def state_factory do
    %Bs.GameState{
      world: build(:world),
      game_form: build(:game_form),
      objective: (fn _ -> false end)
    }
  end
end
