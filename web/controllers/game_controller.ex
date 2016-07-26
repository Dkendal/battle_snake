defmodule BattleSnakeServer.GameController do
  use BattleSnakeServer.Web, :controller

  alias BattleSnakeServer.Game
  alias Snake.World

  def index(conn, _params) do
    games = []
    render(conn, "index.html", games: games)
  end

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"game" => params}) do
    id = Enum.join(Tuple.to_list(:erlang.now), "-")

    world = struct World, game_params(params)

    game = %Game{id: id, state: world}

    :ok = :mnesia.dirty_write(Game, Game.record(game))

    redirect(conn, to: game_path(conn, :show, game))
  end

  def show(conn, %{"id" => id}) do
    [game] = :mnesia.dirty_read Game, id
    game = Game.load(game)

    render(conn, "show.html", game: game)
  end

  def edit(conn, %{"id" => id}) do
  end

  def update(conn, %{"id" => id, "game" => game_params}) do
  end

  def delete(conn, %{"id" => id}) do
  end

  def game_params(params) do
    %{
      width: String.to_integer(params["width"]),
      height: String.to_integer(params["height"]),
    }
  end
end
