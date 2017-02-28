defmodule BattleSnake.GameStateTest do
  alias BattleSnake.GameState

  use BattleSnake.Case, async: false

  @state %GameState{world: 10, hist: [9, 8, 7]}
  @prev %GameState{world: 9, hist: [8, 7]}
  @empty_state %GameState{world: 1, hist: []}

  def ping(pid), do: &send(pid, {:ping, &1})

  describe "GameState.set_winners(t) when everyone is dead" do
    test "sets the winner to whoever died last" do
      world = build(:world,
        snakes: [],
        dead_snakes: [
          build(:snake, id: 1) |> kill_snake(1),
          build(:snake, id: 2) |> kill_snake(2),
          build(:snake, id: 3) |> kill_snake(2)])

      state = build(:state, world: world)
      state = GameState.set_winners(state)
      assert state.winners == [2, 3]
    end
  end

  describe "GameState.set_winners(t)" do
    test "sets the winner to anyone that is still alive" do
      world = build(:world,
        snakes: [
          build(:snake, id: 1)],
        dead_snakes: [
          build(:snake, id: 2) |> kill_snake(1)])

      state = build(:state, world: world)
      state = GameState.set_winners(state)
      assert state.winners == [1]
    end
  end

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

  describe "GameState.step(t)" do
    setup do
      request_move = fn(_, _, _) ->
        {:ok, %HTTPoison.Response{body: "{\"move\":\"up\"}"}}
      end

      mocks = %{request_move: request_move}

      BattleSnake.MockApi.start_link(mocks)
      :ok
    end

    test "sets the winner if the game is done" do
      snake = build(:snake)
      world = build(:world, snakes: [snake])
      state = build(:state, world: world, objective: fn _ -> true end)
      state = GameState.step(state)
      assert state.winners == [snake.id]
    end

    test "doesn't set the winenr" do
      snake = build(:snake)
      world = build(:world, snakes: [snake])
      state = build(:state, world: world, objective: fn _ -> false end)
      state = GameState.step(state)
      assert state.winners == []
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
