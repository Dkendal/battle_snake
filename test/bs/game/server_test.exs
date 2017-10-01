defmodule Bs.Game.ServerTest do
  alias Bs.Case
  alias Bs.Game.Server
  alias Bs.GameState

  use Case, async: false

  def create_game_form(_) do
    [game_form: insert(:game_form)]
  end

  ########
  # Init #
  ########

  describe "Server.init(GameState.t)" do
    test "returns ok" do
      assert {:ok, %GameState{}} = Server.init(build(:state))
    end
  end

  ##################
  # Get Game State #
  ##################

  describe "Server.handle_call(:get_game_state, _, _)" do
    test "returns the state" do
      assert Server.handle_call(:get_game_state, self(), 1) == {:reply, 1, 1}
    end
  end

  ########
  # Tick #
  ########

  describe "Server.handle_info(:tick, state) when status is not :cont" do
    test "does nothing" do
      state = build(:state, status: :hatled)
      assert {:noreply, ^state} = Server.handle_info(:tick, state)
    end
  end

  describe "Server.handle_info(:tick, state) when state.status is cont and game is done" do
    test "halts the game" do
      objective = fn _ -> true end
      state = build(:state, status: :cont, objective: objective)
      assert {:noreply, state} = Server.handle_info(:tick, state)
      assert state.status == :halted
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

  ########
  # Next #
  ########

  describe "Server.handle_call(:next, pid, state)" do
    test "suspends the game" do
      state = build(:state, status: :cont)
      assert {:reply, :ok, state} = Server.handle_call(:next, self(), state)
      assert state.status == :suspend
    end

    test "does nothing when the game is halted" do
      state = build(:state, status: :halted)
      assert {:reply, :ok, ^state} = Server.handle_call(:next, self(), state)
    end
  end

  #########
  # Pause #
  #########

  describe "Server.handle_call(:pause, pid, state)" do
    test "suspends the game" do
      state = build(:state, status: :cont)
      assert {:reply, :ok, state} = Server.handle_call(:pause, self(), state)
      assert state.status == :suspend
    end

    test "does nothing when the game is suspended" do
      state = build(:state, status: :suspend)
      assert {:reply, :ok, ^state} = Server.handle_call(:pause, self(), state)
    end
  end

  ########
  # Prev #
  ########

  describe "Server.handle_call(:prev, pid, state)" do
    test "suspends the game" do
      state = build(:state, status: :halted)
      assert {:reply, :ok, state} = Server.handle_call(:prev, self(), state)
      assert state.status == :suspend
    end
  end

  ##########
  # Resume #
  ##########

  describe "Server.handle_call(:resume, pid, state)" do
    test "continues the game" do
      state = build(:state, status: :suspend)
      assert {:reply, :ok, state} = Server.handle_call(:resume, self(), state)
      assert state.status == :cont
    end

    test "sends a tick message" do
      state = build(:state, status: :suspend)
      assert {:reply, :ok, _state} = Server.handle_call(:resume, self(), state)
      assert_receive :tick, 10
    end
  end

  ##########
  # Replay #
  ##########
end
