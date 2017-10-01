defmodule Bs.Factory do
  use ExMachina.Ecto, repo: BsRepo
  use Bs.Point

  defdelegate sequence(name), to: ExMachina

  def world_factory do
    %Bs.World{
    }
  end

  def snake_form_factory do
    %BsWeb.SnakeForm{
      url: "http://example.com"
    }
  end

  def game_form_factory do
    %BsWeb.GameForm{
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
    game = insert(:game_form)
    %Bs.GameState{
      game_form_id: game.id,
      world: build(:world),
      game_form: game,
      objective: (fn _ -> false end)
    }
  end
end
