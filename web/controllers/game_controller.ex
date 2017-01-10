defmodule BattleSnakeServer.GameController do
  use BattleSnakeServer.Web, :controller

  alias BattleSnakeServer.GameForm

  def index(conn, _params) do
    games = GameForm.all
    render(conn, "index.html", games: games)
  end

  def new(conn, _params) do
    changeset = GameForm.changeset(%GameForm{})

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"game" => params}) do
    game = %GameForm{}
    |> GameForm.changeset(params)
    # |> Ecto.Changeset.put_embed(:world, )
    |> Ecto.Changeset.apply_changes
    |> GameForm.save

    redirect(conn, to: game_path(conn, :edit, game))
  end

  def show(conn, %{"id" => id}) do
    game = GameForm.get(id)

    render(conn, "show.html", game: game)
  end

  def edit(conn, %{"id" => id}) do
    game = GameForm.get(id)

    changeset = GameForm.changeset game

    render(conn, "edit.html", game: game, changeset: changeset)
  end

  def update(conn, %{"id" => id, "game" => params}) do
    game = GameForm.get(id)
    |> GameForm.changeset(params)
    |> Ecto.Changeset.apply_changes
    |> GameForm.save

    redirect(conn, to: game_path(conn, :edit, game))
  end

  def delete(_conn, %{"id" => _id}) do
  end

  def create_params(params) do
    %GameForm{
      width: String.to_integer(params["width"]),
      height: String.to_integer(params["height"]),
    }
  end

  def update_params(_params) do
    %GameForm{
    }
  end
end
