defmodule BattleSnakeWeb.Api.GameController do

  alias BattleSnake.GameServer
  alias BattleSnakeWeb.GameForm

  use BattleSnakeWeb, :controller

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
    |> Mnesia.Repo.save

    render(conn, "show.json", game_form: game_form)
  end

  defp load_games do
    for game_form <- Mnesia.Repo.all(GameForm) do
      status =
        with({:ok, pid} <- GameServer.Registry.find(game_form.id),
             status = GameServer.get_status(pid)) do
          status
        else
          :error ->
            :dead
        end

      import BattleSnake.GameResultSnake

      winners = Mnesia.dirty_index_read(
        BattleSnake.GameResultSnake,
        game_form.id,
        :game_id)

      winners = for t <- winners do
        struct(BattleSnake.GameResultSnake, game_result_snake(t))
      end

      %Game{id: game_form.id,
            winners: winners,
            snakes: game_form.snakes,
            status: status}
    end
  end
end
