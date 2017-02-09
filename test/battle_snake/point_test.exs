defmodule BattleSnake.PointTest do
  use BattleSnake.Case, async: true

  alias BattleSnake.Point

  describe "Poison.Encoder.encode(%BattleSnake.Point{}, [])" do
    test "formats as JSON" do
      point = %Point{x: 1, y: 2}
      expected = [1, 2]
      actual = PoisonTesting.cast!(point)
      assert expected == actual
    end
  end
end
