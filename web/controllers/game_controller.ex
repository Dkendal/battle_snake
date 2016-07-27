defmodule BattleSnakeServer.GameController do
  use BattleSnakeServer.Web, :controller

  alias BattleSnakeServer.Game
  alias Snake.World

  def index(conn, _params) do
    games = Game.all
    render(conn, "index.html", games: games)
  end

  def new(conn, _params) do
    changeset = Game.changeset(%Game{})

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"game" => params}) do
    world = struct(World)

    params = create_params(params)

    game = %Game{params | id: new_id, state: world}

    Game.save(game)

    redirect(conn, to: game_path(conn, :edit, game))
  end

  def show(conn, %{"id" => id}) do
    game = Game.get(id)

    render(conn, "show.html", game: game)
  end

  def edit(conn, %{"id" => id}) do
    game = Game.get(id)

    changeset = Game.changeset game

    render(conn, "edit.html", game: game, changeset: changeset)
  end

  def update(conn, %{"id" => id, "game" => params}) do
    game = Game.get(id)

    game = Game.changeset(game, params)

    game = Ecto.Changeset.apply_changes(game)

    Game.save(game)

    redirect(conn, to: game_path(conn, :edit, game))
  end

  def delete(conn, %{"id" => id}) do
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
