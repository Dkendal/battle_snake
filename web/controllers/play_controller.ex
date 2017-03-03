defmodule BattleSnake.PlayController do
  alias BattleSnake.{GameForm}

  use BattleSnake.Web, :controller

  def show(conn, %{"id" => id} = params) do
    is_replay = params["replay"] == "true"
    {:ok, game_form} = GameForm.get(id)
    render(conn, "show.html", game: game_form, is_replay: is_replay)
  end
end
