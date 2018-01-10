defmodule BsWeb.GameStateView do
  use BsWeb, :view

  def render("show.json", assigns) do
    state = assigns.game_state
    %{
      status: state.status,
      board: render_one(state.world, BsWeb.BoardView, "show.json")
    }
  end
end
