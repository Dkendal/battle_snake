defmodule BattleSnake.GameServerTest do
  alias BattleSnake.GameServer
  alias BattleSnake.GameServer.State

  use ExUnit.Case, async: true

  @opts [delay: 0]
  @state %State{world: 10, hist: [9, 8, 7], opts: @opts}
  @prev %State{world: 9, hist: [8, 7], opts: @opts}
  @empty_state %State{world: 1, hist: []}

  def ping(pid), do: &send(pid, {:ping, &1})

  describe ".handle_info :tick" do
    setup do
      reducer = & &1 + 1
      halt = fn _ -> true end
      cont = fn _ -> false end
      finished = %{@state| reducer: reducer, opts: [objective: halt]}
      running = %{@state| reducer: reducer, opts: [objective: cont, delay: 0]}
      %{finished: finished, running: running}
    end

    test "stops the game if the objective is met", %{finished: state} do
      assert({:noreply, {:halted, _}} =
       GameServer.handle_info(:tick, {:cont, state}))
    end

    test "executes the reducer", %{running: state} do
      assert({_, {_, %{world: 11, hist: [10, 9, 8, 7]}}} =
       GameServer.handle_info(:tick, {:cont, state}))
    end

    test "sends a tick message to itself if the game isn't over", %{running: state} do
      GameServer.handle_info(:tick, {:cont, state})
      assert_receive :tick
    end

    test "maintains the running state", %{running: state} do
      assert({:noreply, {:cont, _}} =
       GameServer.handle_info(:tick, {:cont, state}))
    end
  end

  describe ".handle_call :resume" do
    test "returns ok and sets the state to :cont" do
      assert(GameServer.handle_call(:resume, self, {:suspend, @state}) ==
       {:reply, :ok, {:cont, @state}})
    end

    test "sends a tick message to itself after the caller" do
      GameServer.handle_call(:resume, self, {:suspend, @state})
      assert_receive :tick
    end

    test "does nothing when the game is already running or stopped" do
      assert(GameServer.handle_call(:resume, self, {:cont, 1}) ==
       {:reply, :ok, {:cont, 1}})

      assert(GameServer.handle_call(:resume, self, {:halted, 1}) ==
       {:reply, :ok, {:halted, 1}})
    end
  end

  describe ".handle_call :pause" do
    test "suspend's running games" do
      assert(GameServer.handle_call(:pause, self, {:cont, @state}) ==
       {:reply, :ok, {:suspend, @state}})
    end

    test "does nothing when the game is anything else" do
      assert(GameServer.handle_call(:pause, self, {:suspend, @state}) ==
       {:reply, :ok, {:suspend, @state}})

      assert(GameServer.handle_call(:pause, self, {:halted, @state}) ==
       {:reply, :ok, {:halted, @state}})
    end
  end

  describe ".handle_call :next" do
    test "executes the reducer once if the game is not ended" do
      state = %State{world: 1, reducer: &(&1+1)}

      assert(GameServer.handle_call(:next, self, {:cont, state}) ==
       {:reply, :ok, {:suspend, %{state| world: 2, hist: [1]}}})

      assert(GameServer.handle_call(:next, self, {:suspend, state}) ==
       {:reply, :ok, {:suspend, %{state| world: 2, hist: [1]}}})
    end

    test "does nothing when the game is stopped" do
      assert(GameServer.handle_call(:next, self, {:halted, @state}) ==
       {:reply, :ok, {:halted, @state}})
    end
  end

  describe ".handle_call :prev" do
    test "does nothing when the server is stopped" do
      assert(GameServer.handle_call(:prev, self, {:halted, @state}) ==
        {:reply, :ok, {:halted, @state}})
    end

    test "rewinds to the last move and pauses" do
      assert(GameServer.handle_call(:prev, self, {:suspend, @state}) ==
       {:reply, :ok, {:suspend, @prev}})

      assert(GameServer.handle_call(:prev, self, {:cont, @state}) ==
        {:reply, :ok, {:suspend, @prev}})
    end
  end

  describe ".step_back" do
    test "does nothing when the history is empty" do
      assert GameServer.step_back(@empty_state) == @empty_state
    end

    test "rewinds the state to the last move" do
      assert GameServer.step_back(@state) == @prev
    end

    test "calls the on_change function" do
      state = %{@state| on_change: ping(self)}
      prev = %{@prev| on_change: ping(self)}

      GameServer.step_back(state)

      assert_receive {:ping, ^prev}
    end
  end
end
