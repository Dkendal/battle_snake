defmodule BattleSnake.GameForm.Reset do
  alias BattleSnake.{
    GameForm,
    Snake,
    World,
  }

  @api Application.get_env(:battle_snake, :snake_api)
  @new_snake_length 3

  @moduledoc """
  Sets the initial state of a game form's world attribute.

  Responsible for loading all snakes from the game's initial configuration.
  """

  @spec init_world(GameForm.t) :: GameForm.t
  def init_world(game_form) do
    put_in(game_form.world,
      %World{
        height: game_form.height,
        max_food: game_form.max_food,
        snakes: [],
        width: game_form.width
      })
  end

  @spec reset_game_form(GameForm.t) :: GameForm.t
  def reset_game_form(game_form) do
    game_form = init_world(game_form)
    game_form = Enum.reduce(game_form.snakes, game_form, &load_snake/2)
    update_in(game_form.world, &World.stock_food/1)
  end

  @doc """
  Load the snakes into the world from the snake-form configuration.
  """
  @spec load_snake(SnakeForm.t, GameForm.t) :: GameForm.t
  def load_snake(snake_form, game_form) do
    {:ok, snake} = @api.load(snake_form, game_form)
    snake = reset_snake(game_form.world, snake)
    snake = %{snake| url: snake_form.url}
    update_in(game_form.world.snakes, &[snake|&1])
  end

  @spec reset_snake(World.t, Snake.t) :: Snake.t
  def reset_snake(world, snake) do
    coords = new_coords(world)
    %{snake| coords: coords}
  end

  @spec new_coords(World.t) :: World.t
  def new_coords(world) do
    world
    |> World.rand_unoccupied_space()
    |> List.duplicate(@new_snake_length)
  end
end
