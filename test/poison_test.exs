defmodule PoisonTest do
  use ExUnit.Case, async: true

  describe "BattleSnake.World" do
    test "is encoded" do
      world = %BattleSnake.World{}
      encoding = Poison.encode(world, [])
      assert {:ok, ""} == encoding
    end
  end
end
