defmodule BsWeb.TestCaseErrorView do
  alias Bs.Death.BodyCollisionCause
  alias Bs.Death.HeadCollisionCause
  alias Bs.Death.SelfCollisionCause
  alias Bs.Death.StarvationCause
  alias Bs.Death.WallCollisionCause
  alias Bs.Test.AssertionError
  alias Bs.Test.ConnectionError
  alias Bs.Test.Scenario
  alias BsWeb.BoardView
  alias BsWeb.SnakeView

  use BsWeb, :view

  def render("show.json", %{test_case_error: %ConnectionError{} = err}) do
    reason =
      case err.reason do
        :econnrefused -> dgettext("test", "econnrefused")
      end

    %{
      object: "connection_error",
      reason: reason
    }
  end

  def render("show.json", %{test_case_error: %AssertionError{} = err}) do
    reason =
      case err.player.death do
        %{causes: [%BodyCollisionCause{}]} ->
          dgettext("test", "body collision")

        %{causes: [%HeadCollisionCause{}]} ->
          dgettext("test", "head collision")

        %{causes: [%SelfCollisionCause{}]} ->
          dgettext("test", "self collision")

        %{causes: [%StarvationCause{}]} ->
          dgettext("test", "starvation")

        %{causes: [%WallCollisionCause{}]} ->
          dgettext("test", "wall collision")
      end

    %{
      id: err.world.id,
      object: "assertion_error",
      reason: reason,
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
