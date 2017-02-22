defmodule BattleSnake.SkinController do
  alias BattleSnake.{GameForm}

  use BattleSnake.Web, :controller

  def show(conn, %{"id" => id}) do
    {:ok, game_form} = GameForm.get(id)
    conn
    |> put_layout(false)
    |> put_resp_header("access-control-allow-origin", "*")
    |> render("show.html", game: game_form)
  end
end
