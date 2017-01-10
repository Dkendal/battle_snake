defmodule BattleSnake.GameTest do
  use ExUnit.Case, async: true
  import Ecto.Changeset

  alias BattleSnake.GameForm
  alias BattleSnake.SnakeForm
  alias BattleSnake.{Snake, World}

  describe "#table" do
    test "returns the decleration for mnesia" do
      assert GameForm.table == [attributes: [
        :id,
        :snakes,
        :world,
        :width,
        :height,
        :delay,
        :max_food,
      ]]
    end
  end

  describe "#record" do
    test "converts a struct into a record" do
      game = %GameForm{
        id: 1,
        snakes: [],
        world: %{},
        width: 20,
        height: 40,
        delay: 300,
        max_food: 1,
      }
      assert GameForm.record(game) == {GameForm, 1, [], %{}, 20, 40, 300, 1}
    end
  end

  describe "#load" do
    test "converts a record to a struct" do
      record = {GameForm, 1, [], %{}, 20, 40, 300, 1}

      game = %GameForm{
        id: 1,
        snakes: [],
        world: %{},
        width: 20,
        height: 40,
        delay: 300,
        max_food: 1,
      }

      assert GameForm.load(record) == game
    end
  end

  describe "#set_id" do
    test "adds an id if the id is missing" do
      game = GameForm.changeset %GameForm{id: nil}, %{}
      assert get_field(GameForm.set_id(game), :id) != nil

      game = GameForm.changeset %GameForm{id: 1}, %{}
      assert get_field(GameForm.set_id(game), :id) == 1
    end
  end

  describe "#reset_world" do
    test "sets up a world struct based on this game" do
      game = %GameForm{
        width: 15,
        height: 15,
        max_food: 1,
        snakes: [
          %SnakeForm{
            url: "localhost:4000"
          }
        ],
        world: %World{
          height: 15,
          width: 15,
        }
      }

      world = GameForm.reset_world(game).world

      assert(
        %BattleSnake.World{
          width: 15,
          height: 15,
          food: [_],
          max_food: 1,
        } = world
      )
    end
  end

  describe "#load_snake_form_fn" do
    test "loads the snake" do
      form = %SnakeForm{url: "localhost:4000"}
      world = %World{width: 10, height: 10}
      game = %GameForm{world: world}

      f = GameForm.load_snake_form_fn()
      game = f.(form, game)

      assert([snake] = game.world.snakes)
      assert [_,_,_] = snake.coords
      assert "localhost:4000" == snake.url
    end
  end

  describe "#reset_snake" do
    test "resets the coordinates" do
      snake = %Snake{url: "localhost:4000"}

      world = %World{
        width: 10,
        height: 10,
        snakes: [snake]
      }

      snake = GameForm.reset_snake(world, snake)

      assert(%Snake{
        url: "localhost:4000",
        coords: [_,_,_],
      } = snake)
    end
  end
end
