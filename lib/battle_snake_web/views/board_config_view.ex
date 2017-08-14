defmodule BattleSnakeWeb.BoardConfigView do
  alias BattleSnakeWeb.GameAdminChannel

  use BattleSnakeWeb, :view

  def render("show.json", %{game: game}) do
    %{
      gameId: game.id,
      gameAdminAvailableRequests: GameAdminChannel.available_requests()
    }
  end
end
