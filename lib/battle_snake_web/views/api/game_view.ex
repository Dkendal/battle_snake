defmodule BattleSnakeWeb.Api.GameView do
  use BattleSnakeWeb, :view

  def render("index.json", %{games: games}) do
    games
  end

  def render("show.json", %{game_form: game_form}) do
    game_form
  end
end
