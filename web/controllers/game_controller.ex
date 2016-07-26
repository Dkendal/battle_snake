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
    world = struct(World)
    params = create_params(params)
    game = %Game{params | id: new_id, state: world}
    save(game)

    redirect(conn, to: game_path(conn, :show, game))
  end

  def show(conn, %{"id" => id}) do
    game = load(id)

    render(conn, "show.html", game: game)
  end

  def edit(conn, %{"id" => id}) do
    game = load(id)

    render(conn, "edit.html", game: game)
  end

  def update(conn, %{"id" => id, "game" => params}) do
    game = load(id)

    params = update_params(params)

    callback = fn (_, new, old) ->
      new || old
    end

    game = Map.merge(game, params, callback)

    save(game)

    redirect(conn, to: game_path(conn, :show, game))
  end

  def delete(conn, %{"id" => id}) do
  end

  def load(id) do
    read = fn ->
      :mnesia.read Game, id
    end

    {:atomic, [game]} = :mnesia.transaction read

    Game.load(game)
  end

  def save(game) do
    write = fn ->
      :mnesia.write(Game.record(game))
    end

    {:atomic, :ok} = :mnesia.transaction write

    game
  end

  def create_params(params) do
    %Game{
      width: String.to_integer(params["width"]),
      height: String.to_integer(params["height"]),
    }
  end

  def update_params(_params) do
    %Game{
    }
  end

  def new_id do
    Enum.join(Tuple.to_list(:erlang.now), "-")
  end
end
