defmodule Bs.TestTest do
  alias Bs.Move
  alias Bs.Test
  alias Bs.Test.AssertionError
  alias Bs.Test.ConnectionError
  alias Bs.Test.ChangesetError
  alias Bs.Test.Scenario
  alias Bs.Test.Vector

  use Bs.Case, async: true

  import Bs.Test.Agent, only: :macros
  require Bs.Test.Agent

  @econnrefused %ConnectionError{reason: :econnrefused}

  @changeset_error %ChangesetError{
    changeset: Bs.Move.changeset(%Bs.Move{}, %{move: "UP"})
  }

  @scenario %Scenario{
    player: agent([[0, 0]]),
    agents: [agent([[0, 1]])],
    food: [%Vector{x: 1, y: 0}],
    width: 2,
    height: 2
  }

  @scenarios [
    %Scenario{
      player: agent([[0, 1]]),
      width: 2,
      height: 2
    },
    %Scenario{
      player: agent([[0, 0]]),
      width: 2,
      height: 2
    }
  ]

  test "#start collects results from all scenarios" do
    actual =
      @scenarios
      |> Test.start("up.mock")

    assert [:ok, %AssertionError{}] = actual
  end

  test "#start an error if there is a connection problem" do
    actual =
      @scenarios
      |> Test.start("econnrefused.mock")

    assert @econnrefused in actual
  end

  test "#start an error if the move is invalid" do
    actual =
      @scenarios
      |> Test.start("invalid.mock")

    assert @changeset_error == List.first(actual)
  end

  test "#test passes when the move does not kill the snake" do
    result =
      Test.test(@scenario, "", fn _, _, _ ->
        %Move{move: "right"}
      end)

    assert result == :ok
  end

  test "#test fail when the move does kills the snake" do
    result =
      Test.test(@scenario, "", fn _, _, _ ->
        %Move{move: "down"}
      end)

    assert %Bs.Test.AssertionError{} = result
  end
end
