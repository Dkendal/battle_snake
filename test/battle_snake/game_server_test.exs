defmodule BattleSnake.GameServerTest do
  alias BattleSnake.GameServer
  alias BattleSnake.GameServer.State
  alias BattleSnake.World

  use ExUnit.Case, async: true

  setup do
    world = %World{}
    objective = fn _ -> false end
    opts = [delay: 0, objective: objective]
    f = phone_home(self)

    state = %GameServer.State{world: world, reducer: f, opts: opts}
    {:ok, pid} = GameServer.start_link(state)

    %{pid: pid}
  end

  describe ".resume" do
    test "returns :ok", %{pid: pid} do
      assert :ok = GameServer.resume(pid)
    end

    test "calls the tick function repeatably", %{pid: pid} do
      GameServer.resume(pid)
      assert_receive {:turn, 1}, 100
      assert_receive {:turn, 2}, 100
    end

    test "is idempotent", %{pid: pid} do
      :ok = GameServer.resume(pid)
      :ok = GameServer.resume(pid)
    end
  end

  describe ".handle_call :resume" do
    test "sends a tick message after the delay" do
      state = %State{opts: [delay: 0]}

      assert(GameServer.handle_call(:resume, self, {:suspend, state}) ==
       {:reply, :ok, {:cont, state}})

      assert_receive :tick
    end

    test "does nothing when the game is already running or stopped" do
      assert(GameServer.handle_call(:resume, self, {:cont, 1}) ==
       {:reply, :ok, {:cont, 1}})

      assert(GameServer.handle_call(:resume, self, {:halted, 1}) ==
       {:reply, :ok, {:halted, 1}})
    end
  end

  describe ".pause" do
    test "stops the tick function from being called" do
      world = %World{}
      objective = fn _ -> false end
      opts = [delay: 0, objective: objective]
      f = self_destruct(self)

      state = %GameServer.State{world: world, reducer: f, opts: opts}
      {:ok, pid} = GameServer.start_link(state)

      :ok = GameServer.resume(pid)

      assert_receive {:tick, 1}, 100
      refute_receive {:tick, _}, 100

      :ok = GameServer.resume(pid)

      assert_receive {:tick, 2}, 100
      refute_receive _, 100
    end

    test "is idempotent", %{pid: pid} do
      :ok = GameServer.resume(pid)
      :ok = GameServer.pause(pid)
      :ok = GameServer.pause(pid)
    end
  end

  test ".next" do
    {:ok, pid} = GameServer.start_link %State{world: 1, reducer: &(&1 + 1)}
    GameServer.next(pid)
    GenServer.stop(pid, :normal)
  end

  describe ".handle_call :next" do
    test "executes the reducer once if the game is not ended" do
      state = %State{world: 1, reducer: &(&1+1)}

      assert(GameServer.handle_call(:next, self, {:cont, state}) ==
       {:reply, :ok, {:suspend, %{state| world: 2, hist: [1]}}})

      assert(GameServer.handle_call(:next, self, {:suspend, state}) ==
       {:reply, :ok, {:suspend, %{state| world: 2, hist: [1]}}})

      assert(GameServer.handle_call(:next, self, {:halted, state}) ==
       {:reply, :ok, {:halted, state}})
    end
  end

  def self_destruct(pid) do
    # will get spammed by this
    tick = fn world ->
      send pid, {:tick, world.turn}
    end

    # pause the game after first tick
    fn world ->
      world = update_in world.turn, & &1+1

      tick.(world)

      this = self

      spawn_link fn ->
        GameServer.pause(this)
      end

      world
    end
  end

  def phone_home(pid) do
    fn world ->
      world = update_in world.turn, & &1+1
      send pid, {:turn, world.turn}

      world
    end
  end
end
