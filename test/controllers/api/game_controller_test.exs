defmodule BattleSnake.Api.GameControllerTest do
  alias BattleSnake.GameForm
  alias BattleSnake.GameServer
  use BattleSnake.ConnCase, async: false

  describe "GET index" do
    setup do
      running_game = %GameForm{}
      |> GameForm.changeset(%{})
      |> Ecto.Changeset.apply_changes
      |> GameForm.save

      dead_game = %GameForm{}
      |> GameForm.changeset(%{})
      |> Ecto.Changeset.apply_changes
      |> GameForm.save

      running_game.id

      on_exit fn ->
        :mnesia.clear_table GameForm
      end

      :ok
    end

    test "lists all games", %{conn: conn} do
      conn = get conn, api_game_path(conn, :index)
      assert [%{"game_id" => _,
                "height" => _,
                "width" => _}] =
        json_response(conn, 200)
    end
  end
end
