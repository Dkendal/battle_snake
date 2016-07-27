defmodule BattleSnakeServer.PlayController do
  alias BattleSnakeServer.{Game}

  use BattleSnakeServer.Web, :controller

  def show(conn, %{"id" => id}) do
    game = Game.get(id)
    render(conn, "show.html", game: game)
  end
end
