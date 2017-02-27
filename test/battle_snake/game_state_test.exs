defmodule BattleSnake.GameStateTest do
  alias BattleSnake.GameState

  use BattleSnake.Case, async: false

  @state %GameState{world: 10, hist: [9, 8, 7]}
  @prev %GameState{world: 9, hist: [8, 7]}
  @empty_state %GameState{world: 1, hist: []}

  def ping(pid), do: &send(pid, {:ping, &1})

  describe "GameState.step_back/1" do
    test "does nothing when the history is empty" do
      assert GameState.step_back(@empty_state) == @empty_state
    end

    test "rewinds the state to the last move" do
      assert GameState.step_back(@state) == @prev
    end
  end

  describe "GameState.load_history/1" do
    # TODO: fix random failures
    test "loads a game's history from mnesia" do
      create(:world, game_form_id: 2, turn: 1)

      for t <- (0..3),
        do: create(:world, game_form_id: 1, turn: t)

      state = build(:state, game_form_id: 1)

      state = GameState.load_history(state)

      assert [
        %{turn: 0, game_form_id: 1},
        %{turn: 1, game_form_id: 1},
        %{turn: 2, game_form_id: 1},
        %{turn: 3, game_form_id: 1},
      ] = state.hist
    end
  end

  describe "GameState.step(%{status: :replay})" do
    test "halts the game if the history is empty" do
      state = GameState.replay!(build(:state, hist: []))
      new_state = GameState.step(state)
      assert new_state == GameState.halted!(state)
    end

    test "steps forwards to the next turn" do
      hist = for t <- (0..3), do: build(:world, turn: t)
      state = GameState.replay!(build(:state, hist: hist))
      state = GameState.step(state)

      [h | hist] = hist

      assert state.world == h
      assert state.hist == hist
    end
  end

  for status <- GameState.statuses() do
    method = "#{status}!"
    test "GameState.#{method}/1" do
      assert GameState.unquote(:"#{method}")(@state).status ==
        unquote(status)
    end

    method = "#{status}?"
    test "GameState.#{method}/1" do
      state = put_in @state.status, unquote(status)
      assert GameState.unquote(:"#{method}")(state) == true

      state = put_in @state.status, :__fake_state__
      assert GameState.unquote(:"#{method}")(state) == false
    end
  end
end
