defmodule BattleSnake.Api.GameView do
  use BattleSnake.Web, :view

  def render("index.json", %{games: games}) do
    games
  end

  def render("show.json", %{game_form: game_form}) do
    game_form
  end
end
