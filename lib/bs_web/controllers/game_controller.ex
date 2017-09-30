defmodule BsWeb.GameController do
  alias Bs.Game
  alias BsWeb.GameForm

  use BsWeb, :controller

  def index(conn, _params) do
    games = BsRepo.all GameForm

    game_servers = for game <- games do
      status = if Game.alive?(game.id), do: :alive, else: :dead
      {game, status}
    end

    render(conn, "index.html", games: games, game_servers: game_servers)
  end

  def new(conn, _params) do
    changeset = GameForm.changeset(%GameForm{})

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"game_form" => params}) do
    {:ok, game_form} = %GameForm{}
    |> GameForm.changeset(params)
    |> BsRepo.insert

    redirect(conn, to: game_path(conn, :edit, game_form))
  end

  def show(conn, %{"id" => id}) do
    game_form = BsRepo.get!(GameForm, id)
    render(conn, "show.html", game: game_form)
  end

  def edit(conn, %{"id" => id}) do
    game_form = BsRepo.get!(GameForm, id)
    changeset = GameForm.changeset game_form
    render(conn, "edit.html", game: game_form, changeset: changeset)
  end

  def update(conn, %{"id" => id, "game_form" => params}) do
    game_form = BsRepo.get!(GameForm, id)

    game_form
    |> GameForm.changeset(params)
    |> BsRepo.update

    redirect(conn, to: game_path(conn, :edit, game_form))
  end

  def delete(conn, %{"id" => id}) do
    case BsRepo.get(GameForm, id) do
      nil -> :ok
      x -> BsRepo.delete x
    end
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
