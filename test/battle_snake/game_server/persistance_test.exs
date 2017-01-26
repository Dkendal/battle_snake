defmodule BattleSnake.GameServer.PersistanceTest do
  alias BattleSnake.{
    GameForm,
    GameServer,
    GameServer.State,
  }

  use BattleSnake.Case, async: false

  setup do
    on_exit fn ->
      MnesiaTesting.teardown()
    end
    :ok
  end

  describe "GameServer.Persistance.save_winner/1" do
    setup do
      game_form = %GameForm{}
      |> GameForm.changeset
      |> Ecto.Changeset.apply_changes
      |> Mnesia.Repo.save
      {:ok, state: %State{game_form: game_form, winners: ["winner"]}}
    end

    test "sets the winners on the game form", %{state: state} do
      state = GameServer.Persistance.save_winner(state)
      assert state.game_form.winners == ["winner"]
    end

    test "saves the winners from the state to the game form", %{state: state} do
      GameServer.Persistance.save_winner(state)
      assert [%GameForm{winners: ["winner"]}] = GameForm.all
    end
  end
end
