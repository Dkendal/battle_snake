defmodule BattleSnake.GameServer.ServerTest do
  alias BattleSnake.GameServer.Server
  alias BattleSnake.GameServer.State
  use BattleSnake.Case, async: true

  def create_game_form(_) do
    [game_form: create(:game_form)]
  end

  describe "Server.init(integer)" do
    setup [:create_game_form]

    test "initializes the game state with the id", c do
      assert {:ok, state} = Server.init(c.game_form.id)
      assert state.game_form_id == c.game_form.id
      assert state.game_form.id == c.game_form.id
    end

    test "stops when the game form does not exist" do
      assert {:stop, %Mnesia.RecordNotFoundError{}} = Server.init("fake")
    end
  end

  describe "Server.init(GameForm.t)" do
    setup [:create_game_form]

    test "initializes the game state with the id", c do
      assert {:ok, state} = Server.init(c.game_form)
      assert state.game_form_id == c.game_form.id
      assert state.game_form.id == c.game_form.id
    end
  end

  describe "Server.init(State.t)" do
    test "returns ok" do
      assert {:ok, %State{}} == Server.init(%State{})
    end
  end
end
