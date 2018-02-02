defmodule Bs.TestTest do
  alias Bs.Test
  alias Bs.Test.AssertionError
  alias Bs.Test.Scenario
  alias Bs.Test.Vector

  use Bs.Case, async: false

  import Bs.Test.Agent, only: :macros
  require Bs.Test.Agent

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
    Bs.ApiMock
    |> expect(:start, 2, fn "my.snake", json, _ ->
      assert {:ok, _} = Poison.decode(json)
      %Response{body: ~s({"name":"my-snake"})}
    end)
    |> expect(:move, 2, fn "my.snake", json, _ ->
      assert {:ok, _} = Poison.decode(json)
      %Response{body: ~s({"move":"up"})}
    end)

    actual =
      @scenarios
      |> Test.start("my.snake")

    assert [:ok, %AssertionError{}] = actual
  end

  test "#start an error if there is a connection problem" do
    Bs.ApiMock
    |> expect(:start, fn "my.snake", _, _ ->
      raise Error, reason: :econnrefused
    end)

    actual =
      @scenarios
      |> Test.start("my.snake")

    expected = %HTTPoison.Error{reason: :econnrefused}

    assert expected == List.first(actual)
  end

  test "#start returns an error if one occurs" do
    Bs.ApiMock
    |> expect(:start, 2, fn "my.snake", _, _ ->
      %Response{body: ~s({"name":"my-snake"})}
    end)
    |> expect(:move, 2, fn "my.snake", _, _ ->
      %Response{body: ~s({"move":"UP"})}
    end)

    actual = Test.start(@scenarios, "my.snake")

    expected = %Bs.ChangesetError{
      changeset: Bs.Move.changeset(%Bs.Move{}, %{move: "UP"})
    }

    assert expected == List.first(actual)
  end

  test "#test passes when the move does not kill the snake" do
    Bs.ApiMock
    |> expect(:start, fn "my.snake", _, _ ->
      %Response{body: ~s({"name":"my-snake"})}
    end)
    |> expect(:move, fn "my.snake", _, _ ->
      %Response{body: ~s({"move":"right"})}
    end)

    result = Test.test(@scenario, "my.snake")

    assert result == :ok
  end

  test "#test fail when the move does kills the snake" do
    Bs.ApiMock
    |> expect(:start, fn "my.snake", _, _ ->
      %Response{body: ~s({"name":"my-snake"})}
    end)
    |> expect(:move, fn "my.snake", _, _ ->
      %Response{body: ~s({"move":"down"})}
    end)

    result = Test.test(@scenario, "my.snake")

    assert %Bs.Test.AssertionError{} = result
  end
end
