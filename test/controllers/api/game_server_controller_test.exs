defmodule BattleSnakeWeb.Api.GameServerControllerTest do
  alias BattleSnake.{
    GameServer.Registry,
  }

  use BattleSnakeWeb.ConnCase, async: false

  defmodule G do
    use GenServer
    def handle_call(request, _, caller) do
      send caller, {{:handle_cast, self()}, request}
      {:reply, :ok, caller}
    end
  end

  describe "GameServerController.create/2 when the server can't be started" do
    test "returns the error as json", %{conn: conn} do
      conn = post(conn, api_game_server_path(conn, :create), %{"id" => "1"})
      assert %{"error" => _} = json_response(conn, 200)
    end
  end

  describe "GameServerController.create/2" do
    setup do
      {:ok, pid} = GenServer.start_link(G, self(), name: Registry.via("fake-server"))
      [pid: pid]
    end

    test "starts a new GameServer", %{conn: conn, pid: pid} do
      conn = post(conn, api_game_server_path(conn, :create), %{"id" => "fake-server"})
      assert "ok" == json_response(conn, 200)
      assert_receive {{:handle_cast, ^pid}, :resume}
    end
  end
end
