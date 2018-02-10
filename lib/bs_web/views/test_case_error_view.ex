defmodule BsWeb.TestCaseErrorView do
  alias Bs.Death.BodyCollisionCause
  alias Bs.Death.HeadCollisionCause
  alias Bs.Death.SelfCollisionCause
  alias Bs.Death.StarvationCause
  alias Bs.Death.WallCollisionCause
  alias Bs.Test.AssertionError
  use BsWeb, :view

  def render("show.json", %{
        test_case_error: %{changeset: changeset}
      }) do
    errors =
      Enum.map(changeset.errors, fn {:move, {"is invalid", _}} ->
        dgettext("test", "move is invalid", move: changeset.changes.move)
      end)

    %{object: "error_with_multiple_reasons", errors: errors}
  end

  def render("show.json", %{test_case_error: %AssertionError{} = err}) do
    world = err.world
    player = err.player
    id = world.id
    reason = reason_view(player.death.causes)

    %{
      id: id,
      object: "assertion_error",
      reason: reason,
      scenario: err.scenario,
      board: render_one(world, BsWeb.Board.BoardView, "show.json"),
      player: render_one(player, BsWeb.Board.SnakeView, "show.json")
    }
  end

  def render("show.json", %{test_case_error: %Poison.SyntaxError{} = err}) do
    import Regex
    # FIXME Poison doesn't give you the proper token and position
    # attributes in the error..
    reoi = ~r/Unexpected end of input at position (?<pos>\d+)/
    rtok = ~r/Unexpected token at position (?<pos>\d+): (?<token>\S+)|/

    captures = {
      named_captures(reoi, err.message),
      named_captures(rtok, err.message)
    }

    reason =
      case captures do
        {%{"pos" => pos, "token" => token}, _} ->
          dgettext("test", "unexpected token", %{token: token, pos: pos})

        {_, %{"pos" => "0"}} ->
          dgettext("test", "no input")

        {_, %{"pos" => pos}} ->
          dgettext("test", "unexpected end of input", %{pos: pos})
      end

    %{
      object: "error_with_reason",
      reason: reason
    }
  end

  def render("show.json", %{test_case_error: %{reason: reason}})
      when not is_nil(reason) do
    render("show.json", %{test_case_error: %{message: reason}})
  end

  def render("show.json", %{test_case_error: %{message: message}})
      when is_binary(message) do
    import Regex

    captures =
      ~r/expected params to be a map, got: `(?<token>.+)`/
      |> named_captures(message)

    reason =
      case captures do
        %{"token" => token} ->
          dgettext("test", "expected object", %{token: token})
      end

    %{
      object: "error_with_reason",
      reason: reason
    }
  end

  def render("show.json", %{test_case_error: %{message: message}})
      when not is_nil(message) do
    reason =
      cond do
        message == :econnrefused ->
          dgettext("test", "econnrefused")
      end

    %{
      object: "error_with_reason",
      reason: reason
    }
  end

  def render("show.json", %{test_case_error: :badarg}) do
    %{
      object: "error_with_reason",
      reason: dgettext("test", "badarg")
    }
  end

  def reason_view(causes) do
    case causes do
      [%BodyCollisionCause{}] ->
        dgettext("test", "body collision")

      [%HeadCollisionCause{}] ->
        dgettext("test", "head collision")

      [%SelfCollisionCause{}] ->
        dgettext("test", "self collision")

      [%StarvationCause{}] ->
        dgettext("test", "starvation")

      [%WallCollisionCause{}] ->
        dgettext("test", "wall collision")
    end
  end
end
