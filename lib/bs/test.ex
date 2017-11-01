import Ecto.Changeset

defmodule Bs.Test do
  alias Bs.Movement.Worker
  alias Bs.Test.Agent
  alias Bs.Test.AssertionError
  alias Bs.Test.Scenario
  alias Bs.Test.Vector, as: V
  alias Bs.World

  import List, only: [duplicate: 2]
  import Bs.Test.Vector, only: :macros

  require Bs.Test.Vector

  defmacro agent(ast) do
    body =
      Macro.postwalk(ast, fn
        {:*, _, [x, y]} ->
          quote bind_quoted: [x: x, y: y], do: List.duplicate(x, y)

        [x, y] when is_number(x) and is_number(y) ->
          quote bind_quoted: [x: x, y: y], do: %V{x: x, y: y}

        x ->
          x
      end)

    quote do
      %Agent{
        body: List.flatten(unquote(body))
      }
    end
  end

  def transform(model, f, dim \\ {:error, :error})

  def transform(list, f, dim) when is_list(list) do
    for x <- list, do: transform(x, f, dim)
  end

  def transform(%Scenario{width: width, height: height} = model, f, _dim) do
    model
    |> Map.from_struct()
    |> Enum.reduce(model, fn {k, v}, s ->
         %{s | k => transform(v, f, {width, height})}
       end)
  end

  def transform(%V{x: x, y: y}, f, {w, h}) do
    apply(f, [{w, h}, {x, y}])
  end

  def transform(%{__struct__: _} = model, f, dim) do
    model
    |> Map.from_struct()
    |> Enum.reduce(model, fn {k, v}, s ->
         %{s | k => transform(v, f, dim)}
       end)
  end

  def transform(model, _, _) do
    model
  end

  def scenarios do
    s = [
      # H 0
      # 0 0
      %Scenario{
        width: 2,
        height: 2,
        player: agent([[0, 0] * 3]),
        agents: [],
        food: []
      },
      # H T
      # 0 0
      %Scenario{
        width: 2,
        height: 2,
        player: agent([[0, 0], [1, 0] * 2]),
        agents: [],
        food: []
      },
      # X Y
      # 0 0
      %Scenario{
        width: 2,
        height: 2,
        player: agent([[1, 0] * 2]),
        agents: [agent([[0, 0] * 3])],
        food: []
      }
    ]

    s =
      transform(s, fn {_w, _h}, {x, y} ->
        v(y, x)
      end)

    s =
      transform(s, fn {_w, h}, {x, y} ->
        v(x, h - y - 1)
      end) ++ s

    s = [
      # X Y
      %Scenario{
        width: 2,
        height: 1,
        player: agent([[1, 0] * 3]),
        agents: [agent([[0, 0] * 2])],
        food: []
      }
      | s
    ]

    s =
      transform(s, fn {w, _h}, {x, y} ->
        v(w - x - 1, y)
      end) ++ s

    s
    |> List.flatten()
    |> Enum.uniq()
  end

  def start(scenarios, url) do
    for scenario <- scenarios do
      test(scenario, url)
    end
  end

  def generate_ids(model) when is_map(model) do
    model =
      if Map.has_key?(model, :id) do
        %{model | id: Ecto.UUID.generate()}
      else
        model
      end

    model
    |> Map.from_struct()
    |> Enum.reduce(model, fn {k, v}, model ->
         %{model | k => generate_ids(v)}
       end)
  end

  def generate_ids(model) when is_list(model) do
    Enum.map(model, &generate_ids/1)
  end

  def generate_ids(model) do
    model
  end

  def test(scenario, url, move_fun \\ &Worker.run/3) do
    scenario = generate_ids(scenario)

    {world, player} = Scenario.to_world(scenario)

    player = %{player | url: url}

    move = apply(move_fun, [player, world, [recv_timeout: 5000]])

    player = Bs.Snake.move(player, move)

    snakes = [player | for(x <- world.snakes, x.id != player.id, do: x)]

    world = put_in(world.snakes, snakes)

    world = Bs.Death.reap(world)

    player = World.find_snake(world, player.id)

    if is_nil(player.cause_of_death) do
      :ok
    else
      %AssertionError{
        scenario: scenario,
        player: player,
        world: world
      }
    end
  end
end
