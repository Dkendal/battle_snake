defmodule Bs.Game.RegistryTest do
  alias Bs.Game
  use Bs.Case, async: false

  @id "test-game-server"

  describe "Registry.create/{1,2}" do
    test "registers the process" do
      assert {:ok, game_server} = Game.Registry.create(build(:state), @id)
      assert [{game_server, nil}] == Registry.lookup(Game.Registry, @id)
    end
  end

  describe "Registry.lookup/1" do
    test "fetches the process by the name it was registered under" do
      pid = named_mock_game_server(@id)
      assert [{^pid, nil}] = Game.Registry.lookup(@id)
    end
  end

  describe "Registry.lookup_or_create/2" do
    test "starts the process if it isn't already registered" do
      assert {:ok, _game_server} =
        Game.Registry.lookup_or_create(build(:state), @id)
    end

    test "returns the registered process if it already exists" do
      pid = named_mock_game_server(@id)
      assert {:ok, ^pid} =
        Game.Registry.lookup_or_create(@id)
    end
  end
end
