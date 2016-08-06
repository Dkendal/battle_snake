defmodule BattleSnakeServer.GameTest do
  use ExUnit.Case, async: true
  import Ecto.Changeset

  alias BattleSnakeServer.Game
  alias BattleSnakeServer.Snake, as: Form
  alias BattleSnake.{Snake, World}

  describe "#table" do
    test "returns the decleration for mnesia" do
      assert Game.table == [attributes: [
        :id,
        :snakes,
        :world,
        :width,
        :height,
      ]]
    end
  end

  describe "#record" do
    test "converts a struct into a record" do
      game = %Game{
        id: 1,
        snakes: [],
        world: %{},
        width: 20,
        height: 40,
      }
      assert Game.record(game) == {Game, 1, [], %{}, 20, 40}
    end
  end

  describe "#load" do
    test "converts a record to a struct" do
      record = {Game, 1, [], %{}, 20, 40}

      game = %Game{
        id: 1,
        snakes: [],
        world: %{},
        width: 20,
        height: 40,
      }

      assert Game.load(record) == game
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

  describe "#reset_world" do
    test "sets up a world struct based on this game" do
      game = %Game{
        width: 15,
        height: 15,
        snakes: [
          %Form{
            url: "localhost:4000"
          }
        ],
        world: %World{
          height: 15,
          width: 15,
        }
      }

      world = Game.reset_world(game).world

      assert(
        %BattleSnake.World{
          width: 15,
          height: 15,
          food: [_, _],
          max_food: 2,
        } = world
      )
    end
  end

  describe "#load_snake_form_fn" do
    test "loads the snake" do
      form = %Form{url: "localhost:4000"}
      world = %World{width: 10, height: 10}
      game = %Game{world: world}

      f = Game.load_snake_form_fn()
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

      snake = Game.reset_snake(world, snake)

      assert(%Snake{
        url: "localhost:4000",
        coords: [_,_,_],
      } = snake)
    end
  end
end
