defmodule BattleSnake.Api.GameServerController do
  use BattleSnake.Web, :controller

  def create(conn, %{"id" => id}) do
    render conn, game_server: %{}
  end
end
