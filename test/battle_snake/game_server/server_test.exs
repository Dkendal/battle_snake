defmodule BattleSnake.GameServer.ServerTest do
  alias BattleSnake.GameServer.Server
  alias BattleSnake.GameState
  use BattleSnake.Case, async: false

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

  describe "Server.init(GameState.t)" do
    test "returns ok" do
      assert {:ok, %GameState{}} == Server.init(%GameState{})
    end
  end

  describe "Server.handle_call(:get_game_state, _, _)" do
    test "returns the state" do
      assert Server.handle_call(:get_game_state, self(), 1) == {:reply, 1, 1}
    end
  end

  describe "Server.handle_info(:tick, state) when state.status is cont" do
    test "sends a :tick message after the confiured delay as a lower bound" do
      objective = fn _ -> false end
      state = build(:state, status: :cont, delay: 2, objective: objective)

      Server.handle_info(:tick, state)
      assert_receive :tick, 10
    end

    test "sends a :tick message after execution as an upper bound" do
      objective = fn _ ->
        Process.sleep(2)
        false
      end

      state = build(:state, status: :cont, delay: 0, objective: objective)

      Server.handle_info(:tick, state)
      assert_receive :tick, 10
    end
  end
end
