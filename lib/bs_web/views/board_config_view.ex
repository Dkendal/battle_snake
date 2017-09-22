defmodule BsWeb.BoardConfigView do
  alias BsWeb.GameAdminChannel

  use BsWeb, :view

  def render("show.json", %{game: game}) do
    %{
      gameId: game.id,
      gameAdminAvailableRequests: GameAdminChannel.available_requests()
    }
  end
end
