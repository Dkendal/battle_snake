defmodule Bs.Test.AgentTest do
  alias Bs.Test.Agent
  alias Bs.Test.Vector

  use Bs.Case, async: true

  require Bs.Test.Agent

  import Bs.Test.Agent, only: :macros

  test "#agent string contents" do
    expected =
      ~S"""
      %Bs.Test.Agent{body: List.flatten([(
        x = (
          x = 0
          y = 1
          %Bs.Test.Vector{x: x, y: y}
        )
        y = 3
        List.duplicate(x, y)
      )])}
      """
      |> String.trim()

    actual =
      quote(do: agent([[0, 1] * 3]))
      |> Macro.expand(__ENV__)
      |> Macro.to_string()

    assert expected == actual
  end

  test "#agent" do
    assert %Agent{
             body: [
               %Vector{x: 0, y: 1},
               %Vector{x: 0, y: 1},
               %Vector{x: 0, y: 1}
             ]
           } = agent([[0, 1] * 3])
  end
end
