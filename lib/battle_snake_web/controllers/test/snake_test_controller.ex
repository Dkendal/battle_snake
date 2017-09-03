defmodule BattleSnakeWeb.Test.SnakeTestController do
  use BattleSnakeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
