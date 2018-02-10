defmodule BsWeb.TestCaseErrorViewTest do
  alias Bs.Test.AssertionError
  alias BsWeb.TestCaseErrorView
  use Bs.Case, async: true

  @fail %AssertionError{world: build(:world, id: 1), player: build(:dead_snake)}

  @changeset_error %Bs.ChangesetError{
    changeset: Bs.Move.changeset(%Bs.Move{}, %{move: "UP"})
  }

  @econnrefused %HTTPoison.Error{reason: :econnrefused}

  @syntax %Poison.SyntaxError{
    message: "Unexpected token at position 0: <",
    pos: nil,
    token: "<"
  }

  test "#render a test failure" do
    expected = %{
      id: 1,
      object: "assertion_error",
      reason: "Your snake starved to death.",
      scenario: nil,
      player: %{
        color: "black",
        headType: "regular",
        headUrl: nil,
        health: 100,
        id: nil,
        name: "",
        tailType: "regular",
        taunt: "",
        coords: [%Bs.Point{x: 0, y: 0}],
        status: %Bs.Snake.Status{
          data: %Bs.Death{causes: [%Bs.Death.StarvationCause{}], turn: 1},
          type: :dead
        }
      },
      board: %{
        food: [],
        gameId: 0,
        height: 10,
        id: 1,
        snakes: [],
        turn: 0,
        width: 10
      }
    }

    actual = TestCaseErrorView.render("show.json", %{test_case_error: @fail})

    assert actual == expected
  end

  test "#render a connection failure" do
    expected = %{
      object: "error_with_reason",
      reason:
        "Connection to the server could not be established - are you sure it's running?"
    }

    actual =
      TestCaseErrorView.render("show.json", %{test_case_error: @econnrefused})

    assert actual == expected
  end

  test "#render a changeset error" do
    expected = %{
      object: "error_with_multiple_reasons",
      errors: [
        "The move you provided me, \"UP\", was invalid. Your move should be one of \"up\", \"down\", \"left\", or \"right\", all in lower case."
      ]
    }

    actual =
      TestCaseErrorView.render("show.json", %{
        test_case_error: @changeset_error
      })

    assert actual == expected
  end

  test "#render a syntax error during parsing" do
    expected = %{
      object: "error_with_reason",
      reason:
        "You didn't send anything in the body of your response, I was expecting a JSON body."
    }

    actual =
      TestCaseErrorView.render("show.json", %{
        test_case_error: @syntax
      })

    assert actual == expected
  end
end
