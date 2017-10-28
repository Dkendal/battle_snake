defmodule BsWeb.AssertionErrorView do
  alias BsWeb.SnakeView
  alias BsWeb.BoardView
  alias Bs.Test.Scenario

  use BsWeb, :view

  def render("show.json", %{assertion_error: err}) do
    require Logger

    %{
      id: err.world.id,
      scenario: err.scenario,
      world: render_one(err.world, BoardView, "show.json", v: 2),
      player: render_one(
        err.player,
        SnakeView,
        "show.json",
        v: 2,
        include_render_props: true
      )
    }
  end
end
