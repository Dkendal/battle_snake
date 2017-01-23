defmodule BattleSnake.Api.GameController do
  alias BattleSnake.{
    GameForm
  }

  use BattleSnake.Web, :controller

  def index(conn, __params) do
    games = GameForm.all
    render(conn, "index.json", games: games)
  end
end
