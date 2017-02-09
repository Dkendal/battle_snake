defmodule BattleSnake.MockApiTest do
  alias BattleSnake.MockApi
  use BattleSnake.Case, async: true

  setup do
    game_form = build(:game_form)
    snake_form = build(:snake_form, url: "example.com")
    [game_form: game_form, snake_form: snake_form]
  end

  describe "MockApi.load/2" do
    test "has the same response as BattleSnake.Api", c do
      assert {:ok, %BattleSnake.Snake{name: "mock-snake"}} =
        MockApi.load(c.snake_form, c.game_form).parsed_response
    end
  end

  describe "MockApi.move/2" do
    test "has the same response as BattleSnake.Api", c do
      assert {:ok, %BattleSnake.Move{move: "up"}} =
        MockApi.move(c.snake_form, c.game_form).parsed_response
    end
  end
end
