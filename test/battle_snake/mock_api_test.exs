defmodule BattleSnake.MockApiTest do
  alias BattleSnake.MockApi
  use BattleSnake.Case, async: true

  setup do
    game_form = build(:game_form)
    snake_form = build(:snake_form)
    [game_form: game_form, snake_form: snake_form]
  end

  describe "MockApi.load/2" do
    test "has the same response as BattleSnake.Api", c do
      assert MockApi.load(c.snake_form, c.game_form).parsed_response ==
        BattleSnake.Api.load(c.snake_form, c.game_form, &mock_load/4).parsed_response
    end
  end

  describe "MockApi.move/2" do
    test "has the same response as BattleSnake.Api", c do
      assert MockApi.move(c.snake_form, c.game_form).parsed_response ==
        BattleSnake.Api.move(c.snake_form, c.game_form, &mock_move/4).parsed_response
    end
  end

  def mock_load(_, _, _, _) do
    {:ok,
     %HTTPoison.Response{
       body: Poison.encode!(%{name: "", color: "", url: ""})}}
  end

  def mock_move(_, _, _, _) do
    {:ok,
     %HTTPoison.Response{
       body: Poison.encode!(%{move: "up"})}}
  end
end
