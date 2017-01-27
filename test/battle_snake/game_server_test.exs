defmodule BattleSnake.GameServerTest do
  alias BattleSnake.GameServer
  alias BattleSnake.GameServer.State

  use BattleSnake.Case, async: true

  @opts [delay: 0]
  @state %State{world: 10, hist: [9, 8, 7], opts: @opts}
  @prev %State{world: 9, hist: [8, 7], opts: @opts}
  @empty_state %State{world: 1, hist: []}
  @suspend_state put_in(@state.status, :suspend)
  @cont_state put_in(@state.status, :cont)
  @halt_state put_in(@state.status, :halted)

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
      assert({:noreply, %{status: :halted}} =
       GameServer.handle_info(:tick, put_in(state.status, :cont)))
    end

    test "executes the reducer", %{running: state} do
      assert({_, %{world: 11, hist: [10, 9, 8, 7]}} =
       GameServer.handle_info(:tick, put_in(state.status, :cont)))
    end

    test "sends a tick message to itself if the game isn't over", %{running: state} do
      GameServer.handle_info(:tick, put_in(state.status, :cont))
      assert_receive :tick
    end

    test "maintains the running state", %{running: state} do
      assert({:noreply, %{status: :cont}} =
       GameServer.handle_info(:tick, put_in(state.status, :cont)))
    end
  end

  describe ".handle_call :resume" do
    test "returns ok and sets the state to :cont" do
      assert(GameServer.handle_call(:resume, self(), @suspend_state) ==
        {:reply, :ok, @cont_state})
    end

    test "sends a tick message to itself after the caller" do
      GameServer.handle_call(:resume, self(), @suspend_state)
      assert_receive :tick
    end

    test "does nothing when the game is already running or stopped" do
      assert(GameServer.handle_call(:resume, self(), @cont_state) ==
        {:reply, :ok, @cont_state})

      assert(GameServer.handle_call(:resume, self(), @halt_state) ==
        {:reply, :ok, @halt_state})
    end
  end

  describe ".handle_call :pause" do
    test "suspend's running games" do
      assert(GameServer.handle_call(:pause, self(), @cont_state) ==
       {:reply, :ok, @suspend_state})
    end

    test "does nothing when the game is anything else" do
      assert(GameServer.handle_call(:pause, self(), @suspend_state) ==
       {:reply, :ok, @suspend_state})

      assert(GameServer.handle_call(:pause, self(), @halt_state) ==
       {:reply, :ok, @halt_state})
    end
  end

  describe ".handle_call :next" do
    test "executes the reducer once if the game is not ended" do
      state = %State{world: 1, reducer: &(&1+1)}

      reply = {:reply,
               :ok,
               %{state |
                 status: :suspend,
                 world: 2,
                 hist: [1]}}

      assert(GameServer.handle_call(:next, self(), put_in(state.status, :cont)) ==
        reply)

      assert(GameServer.handle_call(:next, self(), put_in(state.status, :suspend)) ==
        reply)
    end

    test "does nothing when the game is stopped" do
      assert(GameServer.handle_call(:next, self(), @halt_state) ==
       {:reply, :ok, @halt_state})
    end
  end

  describe ".handle_call :prev" do
    test "does nothing when the server is stopped" do
      assert(GameServer.handle_call(:prev, self(), @halt_state) ==
        {:reply, :ok, @halt_state})
    end

    test "rewinds to the last move and pauses" do
      reply = {:reply, :ok, put_in(@prev.status, :suspend)}

      assert(GameServer.handle_call(:prev, self(), @suspend_state) ==
        reply)

      assert(GameServer.handle_call(:prev, self(), @cont_state) ==
        reply)
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
      state = %{@state| on_change: ping(self())}
      prev = %{@prev| on_change: ping(self())}

      GameServer.step_back(state)

      assert_receive {:ping, ^prev}
    end
  end

  describe "BattleSnake.GameServer.get_status/1" do
    test "returns the state of the game server" do
      {:ok, pid} = GameServer.start_link(@state)
      assert :suspend == GameServer.get_status(pid)
    end
  end
end
