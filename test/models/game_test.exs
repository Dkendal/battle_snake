defmodule BattleSnakeServer.GameTest do
  use ExUnit.Case, async: true
  import Ecto.Changeset

  alias BattleSnakeServer.Game

  describe "#table" do
    test "returns the decleration for mnesia" do
      assert Game.table == [attributes: [
        :id,
        :height,
        :snakes,
        :state,
        :width,
      ]]
    end
  end

  describe "#record" do
    test "converts a struct into a record" do
      game = %Game{state: %{}, id: 1, width: 20, height: 40, snakes: []}
      assert Game.record(game) == {Game, 1, 40, [], %{}, 20}
    end
  end

  describe "#load" do
    test "converts a record to a struct" do
      record = {Game, 1, 40, [], %{}, 20}
      assert Game.load(record) == %Game{id: 1, state: %{}, width: 20, height: 40, snakes: []}
    end
  end

  describe "#set_id" do
    test "adds an id if the id is missing" do
      game = Game.changeset %Game{id: nil}, %{}
      assert get_field(Game.set_id(game), :id) != nil

      game = Game.changeset %Game{id: 1}, %{}
      assert get_field(Game.set_id(game), :id) == 1
    end
  end
end
