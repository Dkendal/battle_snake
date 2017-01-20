defmodule BattleSnake.PlayController do
  alias BattleSnake.{GameForm}

  use BattleSnake.Web, :controller

  def show(conn, %{"id" => id}) do
    {:ok, game_form} = GameForm.get(id)
    render(conn, "show.html", game: game_form)
  end
end
