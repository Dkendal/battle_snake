defmodule BattleSnake.PlayController do
  alias BattleSnake.{GameForm}

  use BattleSnake.Web, :controller

  def show(conn, %{"id" => id}) do
    game = GameForm.get(id)
    render(conn, "show.html", game: game)
  end
end
