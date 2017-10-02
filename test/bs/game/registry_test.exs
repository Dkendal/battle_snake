defmodule Bs.Game.RegistryTest do
  alias Bs.Game
  use Bs.Case, async: false

  @id "test-game-server"

  describe "Registry.lookup/1" do
    test "fetches the process by the name it was registered under" do
      pid = named_mock_game_server(@id)
      assert [{^pid, nil}] = Game.Registry.lookup(@id)
    end
  end
end
