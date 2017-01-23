defmodule BattleSnake.Api.GameControllerTest do
  alias BattleSnake.GameForm
  alias BattleSnake.GameServer
  use BattleSnake.ConnCase, async: false

  describe "GET index" do
    setup do
      running_game = %GameForm{}
      |> GameForm.changeset(%{})
      |> Ecto.Changeset.put_change(:id, 1)
      |> Ecto.Changeset.apply_changes
      |> GameForm.save

      dead_game = %GameForm{}
      |> GameForm.changeset(%{})
      |> Ecto.Changeset.put_change(:id, 2)
      |> Ecto.Changeset.apply_changes
      |> GameForm.save

      on_exit fn ->
        :mnesia.clear_table GameForm
      end

      :ok
    end

    test "lists all games", %{conn: conn} do
      conn = get conn, api_game_path(conn, :index)
      assert [%{"id" => 1,
                "status" => "dead"},
              %{"id" => 2,
                "status" => "dead"}] =
        json_response(conn, 200)
    end
  end
end
