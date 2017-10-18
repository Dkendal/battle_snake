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
    snakes = for x <- [scenario.player | scenario.agents], do: Agent.to_snake(x)

    %World{
      snakes: snakes,
      width: scenario.width,
      height: scenario.height,
      food: food
    }
  end
end

defmodule Bs.Test.Move do
  use Ecto.Schema

  embedded_schema do
    field(:move, :string)
  end
end

defmodule Bs.Test do
  alias Bs.Test.Agent
  alias Bs.Test.Vector
  alias Bs.Test.Scenario
  alias Bs.Movement.Worker

  def scenarios do
    [
      %Scenario{
        player: %Agent{body: [%Vector{x: 0, y: 0}]},
        agents: [],
        food: [%Vector{x: 0, y: 0}]
      }
    ]
  end

  def suite(scenarios, url) do
    for scenario <- scenarios do
      test(scenario, url)
    end
  end

  def test(scenario, url) do
    world = Scenario.to_world(scenario)
    snake = Agent.to_snake(scenario.player)
    snake = %{snake | url: url}

    Worker.run(snake, world, recv_timeout: 5000)
  end
end
