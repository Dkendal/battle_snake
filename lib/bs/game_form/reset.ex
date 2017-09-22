defmodule BsWeb.GameForm.Reset do
  alias Bs.Api
  alias Bs.GameForm
  alias Bs.Snake
  alias Bs.World
  alias Ecto.UUID

  @type load_fun :: ((SnakeForm.t, GameForm.t) -> Snake.t)

  @api Application.get_env(:bs, :snake_api)
  @new_snake_length 3

  @moduledoc """
  Sets the initial state of a game form's world attribute.

  Responsible for loading all snakes from the game's initial configuration.
  """

  @spec init_world(GameForm.t) :: GameForm.t
  def init_world(game_form) do
    put_in(game_form.world,
      %World{
        game_form_id: game_form.id,
        height: game_form.height,
        max_food: game_form.max_food,
        snakes: [],
        width: game_form.width,
        game_id: game_form.id
      })
  end

  @spec setup_world(GameForm.t) :: GameForm.t
  def setup_world(game_form) do
    game_form
    |> Map.update!(:world, &World.stock_food/1)
    |> Map.update!(:world, &position_snakes/1)
  end

  def erase_replay(game_form) do
    :mnesia.activity(:transaction, fn ->
      World
      |> :mnesia.index_read(game_form.id, :game_form_id)
      |> Stream.map(&:mnesia.delete_object/1)
      |> Stream.run
    end)
    game_form
  end

  @doc """
  Finds locations for and places snakes in the word.

  Sets the initial coordinates for each snake in world.snakes.
  """
  @spec position_snakes(World.t) :: World.t
  def position_snakes(world) do
    snakes = world.snakes
    world = put_in(world.snakes, [])
    Enum.reduce(snakes, world, fn(snake, world) ->
      snake = reset_snake(world, snake)
      update_in(world.snakes, &[snake|&1])
    end)
  end

  @doc """
  Reset the game_form's .world, setting it to the initial state,
  ready to play.
  """
  @spec reset_game_form(GameForm.t) :: GameForm.t
  def reset_game_form(game_form) do
    game_form
    |> erase_replay()
    |> init_world()
    |> load_snakes()
    |> setup_world()
  end

  @doc """
  Load all snakes from game_form.snakes into game_form.world
  """
  @spec load_snakes(GameForm.t, load_fun) :: GameForm.t
  def load_snakes(game_form, load \\ &@api.load/2) do
    task = fn(snake_form) ->
      snake_form
      |> health_check(game_form, load)
      |> set_id()
      |> set_url(snake_form)
    end

    timeout = 10_000

    update_in(game_form.world.snakes, fn _ ->
      game_form.snakes
      |> Task.async_stream(task, [timeout: timeout])
      |> Enum.map(fn {:ok, snake} -> snake end)
    end)
  end

  @doc """
  Preform a health check on all configured snakes.

  Contacts client endpoints and adds them to the game.

  Clients that respond are marked as healthy, clients that fail to respond are
  marked as unhealthy.

  Reason for being unhealthy is kept in snake.healthy = {:error, reason}
  """
  @spec health_check(SnakeForm.t, GameForm.t, load_fun) :: SnakeForm.t
  def health_check(snake_form, game_form, load \\ &@api.load/2) do
    response = load.(snake_form, game_form)
    with({:ok, snake} <- Api.Response.val(response)) do
      Snake.Health.ok(snake)
    else
      {:error, reason} ->
        Snake.Health.unhealthy(%Snake{}, reason)
    end
  end

  @spec reset_snake(World.t, Snake.t) :: Snake.t
  def reset_snake(world, snake) do
    put_in snake.coords, new_coords(world)
  end

  @spec new_coords(World.t) :: World.t
  def new_coords(world) do
    {:ok, point} = World.rand_unoccupied_space(world)
    List.duplicate(point, @new_snake_length)
  end

  @spec set_url(Snake.t, SnakeForm.t) :: Snake.t
  defp set_url(snake, snake_form) do
    put_in(snake.url, snake_form.url)
  end

  def set_id(snake) do
    put_in(snake.id, UUID.generate())
  end
end
