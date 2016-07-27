defmodule BattleSnakeServer.PlayController do
  use BattleSnakeServer.Web, :controller

  def show(conn, _params) do
    render(conn, "show.html")
  end
end
