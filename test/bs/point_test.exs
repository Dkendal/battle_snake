defmodule Bs.PointTest do
  use Bs.Case, async: true

  alias Bs.Point

  describe "Poison.Encoder.encode(%Bs.Point{}, [])" do
    test "formats as JSON" do
      point = %Point{x: 1, y: 2}
      expected = [1, 2]
      actual = PoisonTesting.cast!(point)
      assert expected == actual
    end
  end
end
