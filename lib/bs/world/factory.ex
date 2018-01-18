alias Bs.Snake
alias Bs.World
alias Bs.Notification
alias Bs.World.Factory.Worker

defmodule Bs.World.Factory do
  @timeout 4900

  def build(%{id: id} = game) when not is_nil(id) do
    world = %World{
      id: Ecto.UUID.generate(),
      game_id: id,
      height: game.height,
      max_food: game.max_food,
      snakes: [],
      width: game.width,
      game_form_id: id
    }

    data =
      Poison.encode!(%{
        game_id: id,
        height: game.height,
        width: game.width
      })

    permalinks = game.snakes

    Notification.broadcast!(
      id,
      name: "restart:init",
      rel: %{game_id: id},
      view: "permalinks.json",
      data: [permalinks: permalinks]
    )

    {:ok, supervisor} =
      Task.Supervisor.start_link(on_timeout: :kill_task, timeout: @timeout)

    stream =
      Task.Supervisor.async_stream_nolink(
        supervisor,
        permalinks,
        Worker,
        :run,
        [id, data]
      )

    snakes =
      stream
      |> Stream.zip(permalinks)
      |> Stream.flat_map(fn
        {{:ok, snake}, _} ->
          Notification.broadcast!(
            id,
            name: "restart:request:ok",
            rel: %{game_id: id, snake_id: snake.id},
            view: "snake_loaded.json",
            data: [snake: snake]
          )

          [snake]

        {{:exit, {error, _stack}}, permalink} ->
          Notification.broadcast!(
            id,
            name: "restart:request:error",
            rel: %{game_id: id, snake_id: permalink.id},
            view: "error.json",
            data: [error: error]
          )

          []
      end)
      |> Enum.to_list()

    Notification.broadcast!(
      id,
      name: "restart:finished",
      rel: %{game_id: id},
      data: %{}
    )

    world = put_in(world.snakes, snakes)

    world = World.stock_food(world)

    update_in(world.snakes, fn snakes ->
      for snake <- snakes do
        {:ok, point} = World.rand_unoccupied_space(world)

        coords = List.duplicate(point, game.snake_start_length)

        put_in(snake.coords, coords)
      end
    end)
  end
end

defmodule Bs.World.Factory.Worker do
  @http Application.get_env(:bs, :http)
  @timeout 4500

  def run(permalink, gameid, opts \\ [])

  def run(%{id: id, url: url}, gameid, data) do
    start_url = "#{url}/start"

    {tc, response} =
      :timer.tc(@http, :post!, [
        start_url,
        data,
        ["content-type": "application/json"],
        [recv_timeout: @timeout]
      ])

    Notification.broadcast!(
      gameid,
      name: "restart:request",
      rel: %{game_id: gameid, snake_id: id},
      view: "response.json",
      data: [
        response: response,
        tc: tc
      ]
    )

    json = Poison.decode!(response.body)

    model = %Snake{url: url, id: id}

    changeset = Snake.changeset(model, json)

    if changeset.valid? do
      Ecto.Changeset.apply_changes(changeset)
    else
      raise changeset.errors
    end
  end
end
