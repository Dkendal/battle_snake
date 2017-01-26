defmodule BattleSnake.GameTest do
  alias BattleSnake.GameForm
  use BattleSnake.Case, async: true
  import Ecto.Changeset

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
        :winners,
        :game_mode
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
        winners: [],
        game_mode: "multiplayer"
      }
      assert GameForm.record(game) == {GameForm, 1, [], %{}, 20, 40, 300, 1, [], "multiplayer"}
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

  describe "Poison.Encoder.encode(%BattleSnake.GameForm{}, [])" do
    @game_form %GameForm{id: 1,
                         height: 2,
                         width: 3}

    @json %{"game_id" => 1,
            "height" => 2,
            "width" => 3}

    @expected PoisonTesting.cast! @game_form

    test "returns formatted JSON" do
      assert @expected == @json
    end
  end
end
