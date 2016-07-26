defmodule BattleSnakeServer.GameController do
  use BattleSnakeServer.Web, :controller

  alias BattleSnakeServer.Game

  def index(conn, _params) do
    games = []
    render(conn, "index.html", games: games)
  end

  def new(conn, _params) do

    render(conn, "new.html")
  end

  def create(conn, %{"game" => game_params}) do
  end

  def show(conn, %{"id" => id}) do
  end

  def edit(conn, %{"id" => id}) do
  end

  def update(conn, %{"id" => id, "game" => game_params}) do
  end

  def delete(conn, %{"id" => id}) do
  end
end
