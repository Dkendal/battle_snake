defmodule BattleSnakeWeb.PlayViewTest do
  use ExUnit.Case

  describe "snake_assets" do
    test "returns a list of all tail images" do
      require BattleSnakeWeb.PlayView

      result = BattleSnakeWeb.PlayView.snake_assets()

      assert [
        id: "snake-head-bendr",
        src: "images/snake/head/bendr.svg"
      ] in result
    end
  end
end
