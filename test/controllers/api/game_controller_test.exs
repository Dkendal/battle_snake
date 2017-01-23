defmodule BattleSnake.Api.GameControllerTest do
  alias BattleSnake.GameForm
  alias BattleSnake.GameServer
  use BattleSnake.ConnCase, async: false

  describe "GET index" do
    setup do
      # TODO repo should get cleaned up after each test.
      MnesiaTesting.teardown

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

      GameServer.Registry.create 1

      on_exit fn ->
        BattleSnake.GameServerTesting.teardown
        MnesiaTesting.teardown
      end

      :ok
    end

    test "lists all games", %{conn: conn} do
      conn = get conn, api_game_path(conn, :index)
      assert [%{"id" => 1,
                "status" => "suspend",
                "winners" => _},
              %{"id" => 2,
                "status" => "dead",
                "winners" => _}] =
        json_response(conn, 200)
    end
  end
end
