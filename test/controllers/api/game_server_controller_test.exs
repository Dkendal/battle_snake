defmodule BattleSnake.Api.GameServerControllerTest do
  alias BattleSnake.{
    GameForm,
    SnakeForm,
  }

  use BattleSnake.ConnCase, async: false

  setup do
    MnesiaTesting.teardown

    snake = %SnakeForm{url: "localhost"}

    %GameForm{}
    |> GameForm.changeset(%{})
    |> Ecto.Changeset.put_change(:id, "1")
    |> Ecto.Changeset.put_embed(:snakes, [snake])
    |> GameForm.save

    on_exit fn ->
      BattleSnake.GameServerTesting.teardown
      MnesiaTesting.teardown
    end

    :ok
  end

  describe "POST create" do
    test "starts a new GameServer", %{conn: conn} do
      conn = post(conn, api_game_server_path(conn, :create), %{"id" => "1"})
      assert "ok" == json_response(conn, 200)
      assert %{active: 1} = Supervisor.count_children(BattleSnake.GameServer.Supervisor)
    end
  end
end
