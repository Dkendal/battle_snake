defmodule BattleSnakeWeb.Api.GameServerView do
  use BattleSnakeWeb, :view

  def render("create.json", %{game_server: game_server})do
    game_server
  end
end
