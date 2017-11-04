defmodule BsWeb.Api.DeathView do
  alias Bs.Death, as: D
  use BsWeb, :view

  def render("show.json", %{death: death}) do
    %{
      causes: render_many(death.causes, __MODULE__, "cause.json"),
      turn: death.turn
    }
  end

  def render("cause.json", %{death: death}) do
    case death do
      %D.BodyCollisionCause{} ->
        "body collision"

      %D.HeadCollisionCause{} ->
        "head collision"

      %D.SelfCollisionCause{} ->
        "self collision"

      %D.StarvationCause{} ->
        "starvation"

      %D.WallCollisionCause{} ->
        "wall collision"

      %D.Cause{} ->
        raise "unknown death cause"
    end
  end
end
