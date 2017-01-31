defmodule BattleSnake.GameServer.StateTest do
  alias BattleSnake.GameServer
  alias BattleSnake.GameServer.State

  use BattleSnake.Case, async: true

  @opts [delay: 0]
  @state %State{world: 10, hist: [9, 8, 7], opts: @opts}
  @prev %State{world: 9, hist: [8, 7], opts: @opts}
  @empty_state %State{world: 1, hist: []}

  def ping(pid), do: &send(pid, {:ping, &1})

  describe "State.step_back/1" do
    test "does nothing when the history is empty" do
      assert State.step_back(@empty_state) == @empty_state
    end

    test "rewinds the state to the last move" do
      assert State.step_back(@state) == @prev
    end

    test "calls the on_change function" do
      state = %{@state| on_change: ping(self())}
      prev = %{@prev| on_change: ping(self())}

      State.step_back(state)

      assert_receive {:ping, ^prev}
    end
  end

  describe "State.load_history/1" do
    test "loads a game's history from mnesia" do
      create(:world, game_form_id: 2, turn: 1)

      for t <- (0..3),
        do: create(:world, game_form_id: 1, turn: t)

      state = build(:state, game_form_id: 1)

      state = State.load_history(state)

      assert [
        %{turn: 0, game_form_id: 1},
        %{turn: 1, game_form_id: 1},
        %{turn: 2, game_form_id: 1},
        %{turn: 3, game_form_id: 1},
      ] = state.hist
    end
  end

  describe "State.step(%{status: :replay})" do
    test "halts the game if the history is empty" do
      state = State.replay!(build(:state, hist: []))
      new_state = State.step(state)
      assert new_state == State.halted!(state)
    end

    test "steps forwards to the next turn" do
      hist = for t <- (0..3), do: build(:world, turn: t)
      state = State.replay!(build(:state, hist: hist))
      state = State.step(state)

      [h | hist] = hist

      assert state.world == h
      assert state.hist == hist
    end

    test "notifies subscribers" do
      id = "1234-5678"
      state = build(:state, game_form_id: id)
      GameServer.PubSub.subscribe(id)
      State.step(state)
      assert_receive %State.Event{name: :tick, data: %State{}}
    end
  end

  for status <- State.statuses() do
    method = "#{status}!"
    test "State.#{method}/1" do
      assert State.unquote(:"#{method}")(@state).status ==
        unquote(status)
    end

    method = "#{status}?"
    test "State.#{method}/1" do
      state = put_in @state.status, unquote(status)
      assert State.unquote(:"#{method}")(state) == true

      state = put_in @state.status, :__fake_state__
      assert State.unquote(:"#{method}")(state) == false
    end
  end
end
