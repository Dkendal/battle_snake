defmodule BattleSnakeServer.PlayController do
  alias BattleSnakeServer.{GameForm}

  use BattleSnakeServer.Web, :controller

  def show(conn, %{"id" => id}) do
    game = GameForm.get(id)
    render(conn, "show.html", game: game)
  end
end
