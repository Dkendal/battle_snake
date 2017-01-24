defmodule BattleSnake.Api.GameServerView do
  use BattleSnake.Web, :view

  def render("create.json", %{game_server: game_server})do
    game_server
  end
end
