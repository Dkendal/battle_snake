defmodule BattleSnake.Test.ExampleController do
  use BattleSnake.Web, :controller

  def start(conn, _params) do
    render(conn, "start.json")
  end

  def move(conn, params) do
    render(conn, "move.json", params)
  end
end
