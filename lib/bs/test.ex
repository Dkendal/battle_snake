defmodule Bs.Test do
  alias Bs.Movement.Worker
  alias Bs.Test.Scenario
  alias Bs.Test.Vector, as: V
  alias Bs.World
  import Bs.Test.Agent, only: :macros
  import Bs.Test.Vector, only: :macros
  require Bs.Test.Agent
  require Bs.Test.Vector

  @moduledoc ~S"""
  Continuous Integration module. This module is responsible for defining test
  cases, and running them against a client.
  """

  # H 0
  # 0 0
  @near_wall %Scenario{
    width: 2,
    height: 2,
    player: agent([[0, 0] * 3]),
    agents: [],
    food: []
  }

  # H T
  # 0 0
  @only_one_move %Scenario{
    width: 2,
    height: 2,
    player: agent([[0, 0], [1, 0] * 2]),
    agents: [],
    food: []
  }

  # X Y
  # 0 0
  @near_opponent %Scenario{
    width: 2,
    height: 2,
    player: agent([[1, 0] * 2]),
    agents: [agent([[0, 0] * 3])],
    food: []
  }

  # X Y
  @head_on %Scenario{
    width: 3,
    height: 1,
    player: agent([[0, 0] * 3]),
    agents: [agent([[1, 0], [2, 0]])],
    food: []
  }

  defmodule(
    AssertionError,
    do:
      defstruct([
        :id,
        :scenario,
        :world,
        :player,
        :reason
      ])
  )

  @shortdoc """
  Run a scenario, returns ok if it passes, or a test case error.
  """
  def test(scenario, url) do
    scenario = generate_ids(scenario)

    {world, player} = Scenario.to_world(scenario)

    json =
      %{game_id: world.id, width: world.width, height: world.height}
      |> Poison.encode!()

    player =
      %{player | url: url}
      |> Bs.World.Factory.Worker.run(json)
      |> Map.put(:coords, player.coords)

    move = Worker.run(player, world, recv_timeout: 5000)

    player = Bs.Snake.move(player, move)

    snakes = [player | for(x <- world.snakes, x.id != player.id, do: x)]

    world = put_in(world.snakes, snakes)

    world = Bs.Death.reap(world)

    player = World.find_snake(world, player.id)

    if is_nil(player.death) do
      :ok
    else
      %AssertionError{
        scenario: scenario,
        player: player,
        world: world
      }
    end
  end

  def scenarios do
    s = [
      @near_wall,
      @only_one_move,
      @near_opponent
    ]

    # swap x and y
    s =
      transform(s, fn {_w, _h}, {x, y} ->
        v(y, x)
      end)

    s = [@head_on | s]

    # flip y
    s =
      transform(s, fn {_w, h}, {x, y} ->
        v(x, h - y - 1)
      end) ++ s

    # flip x
    s =
      transform(s, fn {w, _h}, {x, y} ->
        v(w - x - 1, y)
      end) ++ s

    s
    |> List.flatten()
    |> Enum.uniq()
  end

  def start(scenarios, url) do
    {:ok, sup} = Task.Supervisor.start_link()

    sup
    |> Task.Supervisor.async_stream_nolink(scenarios, __MODULE__, :test, [
      url
    ])
    |> Stream.map(fn
      {:ok, result} ->
        result

      {:exit, {err, _stack}} ->
        err
    end)
    |> Enum.to_list()
  end

  defp transform(model, f, dim \\ {:error, :error})

  defp transform(list, f, dim) when is_list(list) do
    for x <- list, do: transform(x, f, dim)
  end

  defp transform(%Scenario{width: width, height: height} = model, f, _dim) do
    model
    |> Map.from_struct()
    |> Enum.reduce(model, fn {k, v}, s ->
      %{s | k => transform(v, f, {width, height})}
    end)
  end

  defp transform(%V{x: x, y: y}, f, {w, h}) do
    apply(f, [{w, h}, {x, y}])
  end

  defp transform(%{__struct__: _} = model, f, dim) do
    model
    |> Map.from_struct()
    |> Enum.reduce(model, fn {k, v}, s ->
      %{s | k => transform(v, f, dim)}
    end)
  end

  defp transform(model, _, _) do
    model
  end

  defp generate_ids(%mod{} = model) when is_map(model) do
    model =
      if function_exported?(mod, :__schema__, 2) do
        case mod.__schema__(:type, :id) do
          :binary_id ->
            %{model | id: Ecto.UUID.generate()}

          :id ->
            %{model | id: :rand.uniform(999_999_999)}

          nil ->
            model
        end
      else
        model
      end

    model
    |> Map.from_struct()
    |> Enum.reduce(model, fn {k, v}, model ->
      %{model | k => generate_ids(v)}
    end)
  end

  defp generate_ids(model) when is_list(model) do
    Enum.map(model, &generate_ids/1)
  end

  defp generate_ids(model) do
    model
  end
end
