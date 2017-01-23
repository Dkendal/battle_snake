defmodule BattleSnake.Api.GameController do
  alias BattleSnake.{
    GameForm,
    GameServer
  }

  use BattleSnake.Web, :controller

  defmodule Game do
    @derive [Poison.Encoder]
    defstruct [:id, :status]
  end

  def index(conn, __params) do
    games = load_games()
    render(conn, "index.json", games: games)
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
            status: status}
    end
  end
end
