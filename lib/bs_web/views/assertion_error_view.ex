defmodule BsWeb.AssertionErrorView do
  alias BsWeb.SnakeView

  use BsWeb, :view

  def render("show.json", %{assertion_error: err}) do
    %{
      scenario: err.scenario,
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
