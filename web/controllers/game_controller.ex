defmodule BattleSnake.GameController do
  use BattleSnake.Web, :controller

  alias BattleSnake.GameForm

  def index(conn, _params) do
    games = GameForm.all  # => nil

    game_servers = for game <- games do
      status = with [{pid, _}] <- BattleSnake.GameServer.Registry.lookup(game.id) do
        {pid, BattleSnake.GameServer.get_status(pid)}
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
    |> Ecto.Changeset.apply_changes
    |> GameForm.save

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
    |> Ecto.Changeset.apply_changes
    |> GameForm.save

    redirect(conn, to: game_path(conn, :edit, game_form))
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
