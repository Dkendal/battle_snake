alias Bs.Snake
alias Bs.World
alias Bs.World.Factory.Worker

defmodule Bs.World.Factory do
  @timeout 4900
  @sup_options [on_timeout: :kill_task, timeout: @timeout]

  def build(%{id: id} = game) when not is_nil(id) do
    {:ok, supervisor} = Task.Supervisor.start_link(@sup_options)

    configs = game.snakes

    world = %World{
      id: Ecto.UUID.generate(),
      game_id: id,
      height: game.height,
      max_food: game.max_food,
      snakes: [],
      width: game.width,
      game_form_id: id,
      dec_health_points: game.dec_health_points
    }

    request_json =
      %{game_id: id, height: game.height, width: game.width}
      |> Poison.encode!()

    sup_args = [request_json]

    {alive_snakes, dead_snakes} =
      supervisor
      |> Task.Supervisor.async_stream_nolink(configs, Worker, :run, sup_args)
      |> Stream.zip(configs)
      |> Stream.flat_map(&process_snake/1)
      |> Enum.to_list()
      |> Enum.split_with(&Snake.alive?/1)

    world = put_in(world.snakes, alive_snakes)
    world = put_in(world.dead_snakes, dead_snakes)

    world = World.stock_food(world)

    update_in(world.snakes, fn snakes ->
      for snake <- snakes do
        {:ok, point} = World.rand_unoccupied_space(world)

        coords = List.duplicate(point, game.snake_start_length)

        put_in(snake.coords, coords)
      end
    end)
  end

  defp process_snake(result) do
    case result do
      {{:ok, snake}, _} ->
        snake
        |> Snake.alive!()
        |> List.wrap()

      {{:exit, {_error, _stack}}, config} ->
        %Snake{url: config.url, name: config.url, id: config.id}
        |> Snake.connection_failure!()
        |> List.wrap()
    end
  end
end

defmodule Bs.World.Factory.Worker do
  @api Application.get_env(:bs, :api)
  @timeout 4500

  def run(%{id: id, url: url}, json) when is_binary(json) do
    model = %Snake{url: url, id: id}
    options = [recv_timeout: @timeout]
    response = @api.start(url, json, options)
    responseJson = Poison.decode!(response.body)
    changeset = Snake.changeset(model, responseJson)

    if changeset.valid? do
      Ecto.Changeset.apply_changes(changeset)
    else
      raise changeset.errors
    end
  end
end
