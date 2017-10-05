alias Bs.Snake
alias Bs.World
alias Bs.World.Factory.Worker

defmodule Bs.World.Factory do
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

    stream = Task.async_stream(
      snakes,
      Worker,
      :run,
      [id, data]
    )

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

defmodule Bs.World.Factory.Worker do
  @timeout 1000

  def run(permalink, gameid, opts \\ [])
  def run(%{id: id, url: url}, gameid, data) do
    start_url = "#{url}/start"

    {tc, response} = :timer.tc HTTPoison, :post!, [
      start_url,
      data,
      ["content-type": "application/json"],
      [recv_timeout: @timeout]
    ]

    event = %Bs.Event{
      name: :loaded,
      rel: %{game_id: gameid, snake_id: id},
      data: %{
        tc: tc,
        status_code: response.status_code,
        body: response.body
      }
    }

    Bs.Game.PubSub.broadcast!(gameid, event)

    json = Poison.decode! response.body

    model = %Snake{
      url: url,
      id: id,
    }

    changeset = Snake.changeset(model, json)

    if changeset.valid? do
      Ecto.Changeset.apply_changes changeset
    else
      raise changeset.errors
    end
  end
end
