defmodule BattleSnake.GameTest do
  alias BattleSnakeWeb.GameForm
  use BattleSnake.Case, async: true
  import Ecto.Changeset

  describe "#set_id" do
    test "adds an id if the id is missing" do
      game = GameForm.changeset %GameForm{id: nil}, %{}
      assert get_field(GameForm.set_id(game), :id) != nil

      game = GameForm.changeset %GameForm{id: 1}, %{}
      assert get_field(GameForm.set_id(game), :id) == 1
    end
  end

  describe "GameForm.to_game_server_state/1" do
    setup do
      world = build(:world)
      game_form = build(:game_form, delay: 99, id: "0000-0000-0000-0000", world: world)
      state = GameForm.to_game_server_state(game_form)
      [state: state]
    end

    test "sets the game_server_id on the state", %{state: state} do
      assert state.game_form_id == "0000-0000-0000-0000"
    end

    test "copies the delay to the state", %{state: state} do
      assert state.delay == 99
    end

    test "sets the world", %{state: state} do
      assert %BattleSnake.World{} = state.world
    end

    test "sets the objective", %{state: state} do
      assert is_function state.objective
    end
  end

  describe "Poison.Encoder.encode(%BattleSnakeWeb.GameForm{}, [])" do
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
