defmodule BattleSnake.GameServer do
  use GenServer

  @max_history 20

  defmodule State do
    defstruct [
      :world,
      reducer: &State.identity/1,
      on_change: &State.identity/1,
      opts: [],
      hist: []
    ]

    def change(t) do
      t.on_change.(t)
      t
    end

    def identity(x), do: x
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

  def prev(pid) do
    GenServer.call(pid, :prev)
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
    state = step(state)
    {:reply, :ok, {:suspend, state}}
  end

  def handle_call(:prev, _from, {:halted, state}) do
    {:reply, :ok, {:halted, state}}
  end

  def handle_call(:prev, from, {_, state}) do
    state = state
    |> step_back()
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

  # Everything Else

  def handle_info(:tick, {:cont, state}) do
    state = step(state)

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

  def step(state) do
    state
    |> save_history()
    |> apply_reducer()
    |> State.change()
  end

  def step_back(%{hist: []} = s), do: s
  def step_back(state) do
    state
    |> prev_turn
    |> State.change()
  end

  def prev_turn(state) do
    [h|t] = state.hist
    state = put_in state.world, h
    put_in(state.hist, t)
  end

  def save_history(%{world: h} = state) do
    update_in state.hist, fn t ->
      [h |Enum.take(t, @max_history)]
    end
  end

  def apply_reducer(%{world: w, reducer: f} = state) do
    %{state| world: f.(w)}
  end

  # Private

  defp delay(state) do
    opts = state.opts
    Dict.fetch!(opts, :delay)
  end

  defp tick(state) do
    Process.send_after(self(), :tick, delay(state))
  end

  # check if the game is over
  defp done?(state) do
    opts = state.opts
    world = state.world
    fun = Dict.fetch!(opts, :objective)
    fun.(world)
  end
end
