alias Bs.Event
alias Bs.Game.PubSub
alias Bs.Snake
alias Bs.World
alias Bs.World.Factory.Notification
alias Bs.World.Factory.Worker

defmodule Bs.World.Factory do
  @new_snake_length 3

  def build(%{id: id} = game) when not is_nil(id) do
    world = %World{
      game_id: id,
      height: game.height,
      max_food: game.max_food,
      snakes: [],
      width: game.width,
      game_form_id: id,
    }

    data = Poison.encode! %{
      game_id: id,
      height: game.height,
      width: game.width
    }

    snakes = game.snakes

    Notification.broadcast!(
      id,
      name: "restart:init",
      rel: %{game_id: id},
      view: "snakes.json",
      data: [snakes: snakes]
    )

    {:ok, supervisor} = Task.Supervisor.start_link()

    stream = Task.Supervisor.async_stream_nolink(
      supervisor,
      snakes,
      Worker,
      :run,
      [id, data]
    )

    snakes = Stream.flat_map stream, fn
      {:ok, snake} ->
        Notification.broadcast!(
          id,
          name: "restart:request:ok",
          rel: %{game_id: id},
          view: "snake.json",
          data: [snake: snake]
        )

        [snake]

      {:exit, {error, _stack}} ->
        Notification.broadcast!(
          id,
          name: "restart:request:error",
          rel: %{game_id: id},
          view: "error.json",
          data: [error: error]
        )

        []
    end

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

defmodule Bs.World.Factory.Notification do
  def broadcast! id, opts do
    name = Keyword.fetch! opts, :name
    view = Keyword.fetch! opts, :view
    rel = Keyword.fetch! opts, :rel
    data = Keyword.fetch! opts, :data

    PubSub.broadcast!(id, %Event{
      name: name,
      rel: rel,
      data: Phoenix.View.render(
        BsWeb.EventView,
        view,
        data
      )
    })
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

    Notification.broadcast!(
      id,
      name: "restart:request:init",
      rel: %{game_id: gameid, snake_id: id},
      view: "response.json",
      data: [
        response: response,
        tc: tc
      ]
    )

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
