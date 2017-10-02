defmodule Bs.World.Factory do
  alias Bs.Snake
  alias Bs.World

  @timeout 200
  @new_snake_length 3

  def build(game_form) do
    id = game_form.id

    world = %World{
      game_form_id: id,
      height: game_form.height,
      max_food: game_form.max_food,
      snakes: [],
      width: game_form.width,
      game_id: id,
    }

    data = Poison.encode! %{
      game_id: id,
      height: game_form.height,
      width: game_form.width
    }

    snakes = game_form.snakes

    task = fn snake_form ->
      url = snake_form.url
      url = "#{url}/start"

      response = HTTPoison.post!(
        url,
        data,
        ["content-type": "application/json"],
        [recv_timeout: @timeout]
      )

      json = Poison.decode! response.body

      model = %Snake{
        url: snake_form.url,
        id: snake_form.id,
      }

      changeset = Snake.changeset(model, json)

      if changeset.valid? do
        Ecto.Changeset.apply_changes changeset
      else
        raise changeset.errors
      end
    end

    stream = Task.async_stream(snakes, task, [timeout: @timeout])

    snakes = for {:ok, snake} <- stream, do: snake

    world = put_in world.snakes, snakes

    world = World.stock_food world

    update_in world.snakes, fn snakes ->
      for snake <- snakes do
        {:ok, point} = World.rand_unoccupied_space(world)

        coords = List.duplicate(point, @new_snake_length)

        put_in snake.coords, coords
      end
    end
  end
end
