defmodule BsWeb.GameStateView do
  use BsWeb, :view

  def render("show.json", %{game_state: state}) do
    %{
      board: render_one(state.world, BsWeb.BoardView, "show.json")
    }
  end
end
