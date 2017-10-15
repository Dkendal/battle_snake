defmodule BsWeb.BoardConfigView do
  use BsWeb, :view

  def render("show.json", %{game: game}) do
    %{gameId: game.id}
  end
end
