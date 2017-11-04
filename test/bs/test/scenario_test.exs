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
      width: 2,
      height: 2
    }

    actual = Scenario.to_world(scenario)

    assert(
      {
        %World{
          snakes: [
            player,
            %Snake{
              coords: [
                %Point{x: 1, y: 1}
              ]
            }
          ],
          food: [
            %Point{x: 1, y: 0}
          ],
          dead_snakes: [],
          width: 2,
          height: 2
        },
        player
      } = actual
    )

    assert(
      %Snake{
        coords: [
          %Point{x: 0, y: 0}
        ]
      } = player
    )
  end
end
