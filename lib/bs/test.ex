import Ecto.Changeset

defmodule Bs.Test.Agent do
  alias Bs.Test.Vector
  alias Bs.Snake

  use Ecto.Schema

  embedded_schema do
    embeds_many(:body, Vector)
  end

  def to_snake(agent) do
    coords = for x <- agent.body, do: Vector.to_point(x)

    %Snake{
      id: agent.id,
      coords: coords
    }
  end
end

defmodule Bs.Test.Vector do
  alias Bs.Point

  use Ecto.Schema

  @primary_key false

  embedded_schema do
    field(:x, :integer)
    field(:y, :integer)
  end

  def to_point(vector) do
    %Point{
      x: vector.x,
      y: vector.y
    }
  end
end

defmodule Bs.Test.Scenario do
  alias Bs.Test.Agent
  alias Bs.Test.Vector
  alias Bs.World

  use Ecto.Schema

  embedded_schema do
    field(:width, :integer)
    field(:height, :integer)
    embeds_one(:player, Agent)
    embeds_many(:agents, Agent)
    embeds_many(:food, Vector)
  end

  def to_world(scenario) do
    food = for x <- scenario.food, do: Vector.to_point(x)

    snakes =
      for x <- [scenario.player | scenario.agents] do
        Agent.to_snake(x)
      end

    [player | _] = snakes

    world = %World{
      id: scenario.id,
      game_id: scenario.id,
      snakes: snakes,
      width: scenario.width,
      height: scenario.height,
      food: food
    }

    {world, player}
  end
end

defmodule Bs.Test.Move do
  use Ecto.Schema

  embedded_schema do
    field(:move, :string)
  end
end

defmodule Bs.Test.AssertionError do
  defstruct [
    :scenario,
    :world,
    :player
  ]
end

defmodule Bs.Test do
  alias Bs.Movement.Worker
  alias Bs.Test.Agent
  alias Bs.Test.AssertionError
  alias Bs.Test.Scenario
  alias Bs.Test.Vector, as: V
  alias Bs.World

  import List, only: [duplicate: 2]

  def scenarios do
    [
      %Scenario{
        width: 2,
        height: 2,
        player: %Agent{
          body: duplicate(%V{x: 0, y: 1}, 3)
        },
        agents: [],
        food: []
      },
      %Scenario{
        width: 2,
        height: 2,
        player: %Agent{body: duplicate(%V{x: 0, y: 0}, 3)},
        agents: [],
        food: []
      }
    ]
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
