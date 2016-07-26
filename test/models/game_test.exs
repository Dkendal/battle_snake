defmodule BattleSnakeServer.GameTest do
  use ExUnit.Case, async: true

  alias BattleSnakeServer.Game

  describe "#table" do
    test "returns the decleration for mnesia" do
      assert Game.table == [attributes: [:id, :state]]
    end
  end

  describe "#record" do
    test "converts a struct into a record" do
      game = %Game{state: %{}, id: 1}
      assert Game.record(game) == {Game, 1, %{}}
    end
  end
end
