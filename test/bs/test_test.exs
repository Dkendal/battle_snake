defmodule Bs.TestTest do
  alias Bs.Test
  alias Bs.Test.Agent
  alias Bs.Test.Vector
  alias Bs.Test.Scenario
  alias Bs.Move

  use Bs.Case, async: true

  require Bs.Test.Agent

  test "#start collects results from all scenarios" do
    scenarios = [
      %Scenario{
        player: %Agent{body: [%Vector{x: 0, y: 0}]},
        agents: [%Agent{body: [%Vector{x: 0, y: 1}]}],
        food: [%Vector{x: 1, y: 0}],
        width: 2,
        height: 2
      }
    ]

    actual =
      scenarios
      |> Test.start("up.mock")

    assert [_] = actual
  end

  test "#test passes when the move does not kill the snake" do
    scenario = %Scenario{
      player: %Agent{body: [%Vector{x: 0, y: 0}]},
      agents: [%Agent{body: [%Vector{x: 0, y: 1}]}],
      food: [%Vector{x: 1, y: 0}],
      width: 2,
      height: 2
    }

    result =
      Test.test(scenario, "", fn _, _, _ ->
        %Move{move: "right"}
      end)

    assert result == :ok
  end

  test "#test fail when the move does kills the snake" do
    scenario = %Scenario{
      player: %Agent{body: [%Vector{x: 0, y: 0}]},
      agents: [%Agent{body: [%Vector{x: 0, y: 1}]}],
      food: [%Vector{x: 1, y: 0}],
      width: 2,
      height: 2
    }

    result =
      Test.test(scenario, "", fn _, _, _ ->
        %Move{move: "down"}
      end)

    assert %Bs.Test.AssertionError{} = result
  end
end
