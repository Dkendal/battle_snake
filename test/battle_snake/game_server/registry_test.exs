defmodule BattleSnake.GameServer.RegistryTest do
  alias BattleSnake.GameServer
  use BattleSnake.Case, async: false

  @state %GameServer.State{}
  @game_server_name "test-game-server"

  describe "BattleSnake.GameServer.Registry.create/2" do
    test "registers the process" do
      assert {:ok, game_server} = GameServer.Registry.create(@game_server_name, @state)
      assert [{game_server, nil}] == Registry.lookup(GameServer.Registry, @game_server_name)
    end
  end

  describe "BattleSnake.GameServer.Registry.lookup/1" do
    setup [:start_game_server]

    test "fetches the process by the name it was registered under", %{game_server: game_server} do
      assert [{game_server, nil}] == GameServer.Registry.lookup(@game_server_name)
    end
  end

  describe "BattleSnake.GameServer.Registry.lookup_or_create/2" do
    test "starts the process if it isn't already registered" do
      assert {:ok, _game_server} =
        GameServer.Registry.lookup_or_create(@game_server_name, @state)
    end

    test "returns the registered process if it already exists" do
      %{game_server: game_server} = start_game_server()

      assert {:ok, ^game_server} =
        GameServer.Registry.lookup_or_create(@game_server_name, @state)
    end
  end

  def start_game_server(context \\ %{}) do
    {:ok, game_server} = GameServer.Registry.create(@game_server_name, @state)
    Map.put(context, :game_server, game_server)
  end
end
