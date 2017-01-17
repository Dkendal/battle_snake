defmodule BattleSnake.GameForm.ResetTest do
  use ExUnit.Case, async: true

  @game_form %BattleSnake.GameForm{
    delay: 100,
    max_food: 1,
    height: 10,
    width: 20
  }

  @world %BattleSnake.World{
    width: 20,
    height: 10
  }

  @snake_form %BattleSnake.SnakeForm{
    url: "http://example.com"
  }

  @game_form_with_snakes put_in(@game_form.snakes, [@snake_form])

  @initialized_game_form put_in(@game_form.world, @world)

  describe "BattleSnake.GameForm.Reset.init_world/1" do
    @init_world BattleSnake.GameForm.Reset.init_world(@game_form)

    test "returns a BattleSnake.GameForm struct" do
      assert(match?(%BattleSnake.GameForm{}, @init_world))
    end

    test "sets game_form.world.width based on config" do
      assert(@init_world.world.width == 20)
    end

    test "sets game_form.world.height based on config" do
      assert(@init_world.world.height == 10)
    end

    test "sets game_form.world.max_food based on config" do
      assert(@init_world.world.max_food == 1)
    end

    test "empties game_form.world.snakes" do
      assert(@init_world.world.snakes == [])
    end
  end

  describe "BattleSnake.GameForm.Reset.load_snake/2" do
    @load_snake BattleSnake.GameForm.Reset.load_snake(@snake_form, @initialized_game_form)
    @loaded_snake @load_snake.world.snakes |> hd

    test "adds a snake to game_form.world.snakes" do
      assert(match?([%BattleSnake.Snake{}], @load_snake.world.snakes))
    end

    test "loaded snake has the same url as snake_form" do
      assert(@loaded_snake.url == "http://example.com")
    end

    test "loaded snake has some position on the board" do
      assert(@loaded_snake.coords |> length() > 0)
    end
  end

  describe "BattleSnake.GameForm.Reset.reset_game_form/1" do
    @reset_game_form BattleSnake.GameForm.Reset.reset_game_form(@game_form_with_snakes)

    test "adds snakes to the world based on the config" do
      assert(@reset_game_form.world.snakes |> length() == 1)
    end

    test "adds food to the world based on the config" do
      assert(@reset_game_form.world.food |> length() == 1)
    end
  end
end
