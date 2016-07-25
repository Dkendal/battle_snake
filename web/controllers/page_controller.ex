defmodule BattleSnakeServer.PageController do
  use BattleSnakeServer.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
