defmodule BsWeb.PlayController do
  alias BsWeb.GameForm

  use BsWeb, :controller

  def show(conn, %{"id" => id} = params) do
    is_replay = params["replay"] == "true"
    game_form = BsRepo.get GameForm, id
    render(conn, "show.html", game: game_form, is_replay: is_replay)
  end
end
