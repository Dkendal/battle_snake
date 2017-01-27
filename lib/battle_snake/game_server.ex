defmodule BattleSnake.GameServer do
  alias __MODULE__.State
  use GenServer

  @type state :: State.t

  # Begin Client Api

  def start_link(state, opts \\ [])
  def start_link(%State{} = state, opts) do
    state = State.on_start(state)
    GenServer.start_link(__MODULE__, state, opts)
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def get_status(pid) do
    GenServer.call(pid, :get_status)
  end

  def next(pid) do
    GenServer.call(pid, :next)
  end

  def on_change(pid),
    do: GenServer.call(pid, :on_change)

  def on_done(pid),
    do: GenServer.call(pid, :on_done)

  def on_start(pid),
    do: GenServer.call(pid, :on_start)

  def pause(pid) do
    GenServer.call(pid, :pause)
  end

  def prev(pid) do
    GenServer.call(pid, :prev)
  end

  def resume(pid) do
    GenServer.call(pid, :resume)
  end

  defp tick(state) do
    Process.send_after(self(), :tick, State.delay(state))
  end

  # End Client Api

  # Begin Server Callbacks

  def handle_call(:get_status, _from, state) do
    {:reply, state.status, state}
  end

  def handle_call(:next, _from, state) do
    case state.status do
      :halted ->
        {:reply, :ok, put_in(state.status, :halted)}

      _ ->
        state = State.step(state)
        {:reply, :ok, put_in(state.status, :suspend)}
    end
  end

  def handle_call(:on_change, _from, {status, state}) do
    state = State.on_change(state)
    {:reply, :ok, {status, state}}
  end

  def handle_call(:on_done, _from, {status, state}) do
    state = State.on_done(state)
    {:reply, :ok, {status, state}}
  end

  def handle_call(:on_start, _from, {status, state}) do
    state = State.on_start(state)
    {:reply, :ok, {status, state}}
  end

  def handle_call(:pause, _from, state) do
    case state.status do
      :cont ->
        {:reply, :ok, put_in(state.status, :suspend)}

      _status ->
        {:reply, :ok, state}
    end
  end

  def handle_call(:prev, _from, state) do
    case state.status do
      :halted ->
        {:reply, :ok, put_in(state.status, :halted)}

      _status ->
        state = state
        |> State.step_back()
        {:reply, :ok, put_in(state.status, :suspend)}
    end
  end

  def handle_call(:resume, _from, state) do
    case state.status do
      :suspend ->
        tick(state)
        {:reply, :ok, put_in(state.status, :cont)}

      _status ->
        {:reply, :ok, state}
    end
  end

  def handle_call(request, from, state) do
    # Call the default implementation from GenServer
    super(request, from, state)
  end

  def handle_cast(request, state) do
    super(request, state)
  end

  def handle_info(:get_state, state) do
    {:reply, state, state.status}
  end

  def handle_info(:tick, state) do
    case state.status do
      :cont ->
        state = State.step(state)
        if State.done?(state) do
          state = State.on_done(state)
          {:noreply, put_in(state.status, :halted)}
        else
          tick(state)
          {:noreply, put_in(state.status, :cont)}
        end

      :halted ->
        {:noreply, put_in(state.status, :halted)}

      :suspend ->
        {:noreply, put_in(state.status, :suspend)}
    end
  end

  def handle_info(request, state) do
    super(request, state)
  end

  # End Server Callbacks
end
