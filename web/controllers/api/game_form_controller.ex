defmodule BattleSnake.Api.GameFormController do
  alias BattleSnake.{
    GameForm,
    GameServer
  }

  use BattleSnake.Web, :controller

  defmodule Game do
    @derive [Poison.Encoder]
    defstruct [:id, :status, :winners, :snakes]
  end

  def index(conn, _params) do
    games = load_games()
    render(conn, "index.json", games: games)
  end

  def create(conn, %{"game_form" => game_form}) do
    game_form = %GameForm{}
    |> GameForm.changeset(game_form)
    |> Ecto.Changeset.apply_changes
    |> GameForm.save

    render(conn, "show.json", game_form: game_form)
  end

  defp load_games do
    for game_form <- GameForm.all do
      status =
        with({:ok, pid} <- GameServer.Registry.find(game_form.id),
             status = GameServer.get_status(pid)) do
          status
        else
          :error ->
            :dead
        end

      %Game{id: game_form.id,
            winners: game_form.winners,
            snakes: game_form.snakes,
            status: status}
    end
  end
end
