defmodule BsWeb.GameController do
  alias Bs.Game
  alias Bs.Game.Registry
  alias BsWeb.GameForm
  alias Ecto.Changeset
  alias Mnesia.Repo

  use BsWeb, :controller

  def index(conn, _params) do
    games = Repo.all(GameForm)

    game_servers = for game <- games do
      status = with [{pid, _}] <- Registry.lookup(game.id) do
        {pid, Game.get_status(pid)}
      else
        [] -> :dead
      end
      {game, status}
    end

    render(conn, "index.html", games: games, game_servers: game_servers)
  end

  def new(conn, _params) do
    changeset = GameForm.changeset(%GameForm{})

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"game_form" => params}) do
    game_form = %GameForm{}
    |> GameForm.changeset(params)
    |> Changeset.apply_changes
    |> Repo.save

    redirect(conn, to: game_path(conn, :edit, game_form))
  end

  def show(conn, %{"id" => id}) do
    {:ok, game_form} = GameForm.get(id)
    render(conn, "show.html", game: game_form)
  end

  def edit(conn, %{"id" => id}) do
    {:ok, game_form} = GameForm.get(id)
    changeset = GameForm.changeset game_form
    render(conn, "edit.html", game: game_form, changeset: changeset)
  end

  def update(conn, %{"id" => id, "game_form" => params}) do
    {:ok, game_form} = GameForm.get(id)
    game_form
    |> GameForm.changeset(params)
    |> Changeset.apply_changes
    |> Repo.save

    redirect(conn, to: game_path(conn, :edit, game_form))
  end

  def delete(conn, %{"id" => id}) do
    GameForm |> Repo.delete(id)
    index(conn, {})
  end

  def create_params(params) do
    %GameForm{
      width: String.to_integer(params["width"]),
      height: String.to_integer(params["height"]),
    }
  end

  def update_params(_params) do
    %GameForm{}
  end
end
