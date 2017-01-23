defmodule BattleSnake.Api.GameView do
  use BattleSnake.Web, :view

  def render("index.json", %{games: games}) do
    games
  end
end
