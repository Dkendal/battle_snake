defmodule BattleSnake.GameServer do
  use GenServer

  defmodule State do
    defstruct [:world, :reducer, opts: []]
  end

  # Client

  def start_link(%State{} = state, opts \\ []) do
    GenServer.start_link(__MODULE__, {:suspend, state}, opts)
  end

  def resume(pid) do
    GenServer.call(pid, :resume)
  end

  def pause(pid) do
    GenServer.call(pid, :pause)
  end

  def next(pid) do
    GenServer.call(pid, :next)
  end

  # Server (callbacks)

  # Calls
  def handle_call(:pause, _from, {:cont, state}) do
    {:reply, :ok, {:suspend, state}}
  end

  # calling pause on an already paused or stopped game has no effect
  def handle_call(:pause, _from, state) do
    {:reply, :ok, state}
  end


  def handle_call(:resume, _from, {:suspend, state}) do
    tick(state)
    {:reply, :ok, {:cont, state}}
  end

  # calling resume on an already running game or stopped game doesn't do
    # anything
  def handle_call(:resume, _from, state) do
    {:reply, :ok, state}
  end

  def handle_call(:next, _from, {:halted, state}) do
    {:reply, :ok, {:halted, state}}
  end

  def handle_call(:next, _from, {_, state}) do
    state = apply_reducer(state)
    {:reply, :ok, {:suspend, state}}
  end

  def handle_call(request, from, state) do
    # Call the default implementation from GenServer
    super(request, from, state)
  end

  # Casts

  def handle_cast(request, state) do
    super(request, state)
  end

  #
  def handle_info(:tick, {:cont, state}) do
    state = apply_reducer(state)
    if done?(state) do
      {:noreply, {:halted, state}}
    else
      tick(state)
      {:noreply, {:cont, state}}
    end
  end

  def handle_info(:tick, {:suspend, state}) do
    {:noreply, {:suspend, state}}
  end

  def handle_info(:tick, {:halted, state}) do
    {:noreply, {:halted, state}}
  end

  # Private

  defp delay(state) do
    opts = state.opts
    Dict.fetch!(opts, :delay)
  end

  defp tick(state) do
    Process.send_after(self(), :tick, delay(state))
  end

  defp apply_reducer(state) do
    %{state| world: state.reducer.(state.world)}
  end

  # check if the game is over
  defp done?(state) do
    opts = state.opts
    world = state.world
    fun = Dict.fetch!(opts, :objective)
    fun.(world)
  end
end
