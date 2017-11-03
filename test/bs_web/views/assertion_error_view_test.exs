defmodule BsWeb.AssertionErrorViewTest do
  alias BsWeb.AssertionErrorView
  alias Bs.Test.AssertionError

  use Bs.Case, async: true

  test "#render" do
    assertion_error = %AssertionError{
      world: build(:world)
    }

    expected = %{
      id: nil,
      player: nil,
      scenario: nil,
      world: %{
        deadSnakes: [],
        food: [],
        gameId: 0,
        height: 10,
        snakes: [],
        turn: 0,
        width: 10
      }
    }

    actual =
      AssertionErrorView.render("show.json", %{assertion_error: assertion_error})

    assert actual == expected
  end
end
