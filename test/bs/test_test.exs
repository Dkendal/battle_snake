defmodule Bs.TestTest do
  alias Bs.Test
  alias Bs.Test.Agent
  alias Bs.Test.Move
  alias Bs.Test.Vector
  alias Bs.Test.Scenario

  use Bs.Case, async: true

  test "#test" do
    url = "http://localhost:4000"

    scenario = %Scenario{
      player: %Agent{body: [%Vector{x: 0, y: 0}]},
      agents: [],
      food: [%Vector{x: 1, y: 0}],
      width: 4,
      height: 4
    }

    assert Test.test(scenario, url)
  end
end

defmodule Bs.Test.ScenarioTest do
  alias Bs.Test.Agent
  alias Bs.Test.Vector
  alias Bs.Test.Scenario

  alias Bs.World
  alias Bs.Snake
  alias Bs.Point

  use Bs.Case, async: true

  test "#to_world" do
    scenario = %Scenario{
      player: %Agent{body: [%Vector{x: 0, y: 0}]},
      agents: [%Agent{body: [%Vector{x: 1, y: 1}]}],
      food: [%Vector{x: 1, y: 0}],
      width: 4,
      height: 4
    }

    actual = Scenario.to_world(scenario)

    expected = %World{
      snakes: [
        %Snake{
          coords: [
            %Point{x: 0, y: 0}
          ]
        },
        %Snake{
          coords: [
            %Point{x: 1, y: 1}
          ]
        },
      ],
      food: [
        %Point{x: 1, y: 0}
      ],
      dead_snakes: [],
      width: 4,
      height: 4
    }

    assert expected == actual
  end
end
