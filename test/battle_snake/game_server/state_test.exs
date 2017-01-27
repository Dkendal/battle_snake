defmodule BattleSnake.GameServer.StateTest do
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
end
